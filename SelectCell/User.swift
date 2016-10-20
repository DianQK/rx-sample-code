//
//  User.swift
//  SelectCell
//
//  Created by DianQK on 20/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Contacts
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

struct User {
    let id: String
    let name: String
    let alphabet: String
    let isSelected: Variable<Bool>
}

typealias UserSectionModel = SectionModel<String, User>

/// 获取用户
func getUsers() -> Observable<[User]> {
    return Observable.just(CNContactStore(), scheduler: SerialDispatchQueueScheduler(qos: .background))
        .flatMap(requestAccess)
        .map(fetchContacts)
        .map(convertContactsToUsers)
        .observeOn(MainScheduler.instance)
}

/// 请求获取通讯录权限
let requestAccess: (CNContactStore) -> Observable<CNContactStore> = { store in
    return Observable<CNContactStore>
        .create { (observer) -> Disposable in
            if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
                store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: Error?) -> Void in
                    if authorized {
                        observer.on(.next(store))
                        observer.on(.completed)
                    } else if let error = error {
                        observer.on(.error(error))
                    }
                })
            } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
                observer.on(.next(store))
                observer.on(.completed)
            }
            return Disposables.create()
    }
}

/// 拉取通讯录
let fetchContacts: (CNContactStore) throws -> [CNContact] = { store in
    let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
    let allContainers = try store.containers(matching: nil)
    let result = try allContainers.flatMap { (container) -> [CNContact] in
        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
        return try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
    }
    return result
}

/// 将 CNContact 转换成 User
let convertContactsToUsers: ([CNContact]) -> [User] = { contacts in
    contacts
        .filter { !$0.givenName.isEmpty }
        .map { contact in
            let name = contact.familyName.isEmpty ? contact.givenName : (contact.familyName + contact.givenName)
            return User(id: contact.identifier, name: name, alphabet: name.mandarinLatin.uppercased().first!, isSelected: Variable(false))
    }
}

/// 将 Users 转换成 UserSectionModels
let convertUsersToSections: ([User]) -> [UserSectionModel] = { users in
    users
        .sorted(by: { (l, r) -> Bool in
            l.alphabet <= r.alphabet
        })
        .reduce([UserSectionModel](), { (acc, x) in
            if var last = acc.last, x.alphabet.hasPrefix(last.model) {
                last.items.append(x)
                return acc.dropLast() + [last]
            } else {
                return acc + [UserSectionModel(model: x.alphabet, items: [x])]
            }
        })
}

let combineSelectedUsersInfo: ([User]) -> String = { users in
    combineUsersInfo(users.filter { $0.isSelected.value })
}

let combineUsersInfo:  ([User]) -> String = { users in
    users.map { $0.name }.joined(separator: ",")
}

extension String {
    var mandarinLatin: String {
        let mutableString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        return mutableString as String
    }
}

extension String {
    var first: String? {
        return substring(to: index(after: startIndex))
    }
}
