//
//  SkinDataSource.swift
//  SelectCell
//
//  Created by DianQK on 20/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import RxDataSources

func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<UserSectionModel>) {
    dataSource.configureCell = { dataSource, tableView, indexPath, element in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        cell.textLabel?.text = element.name
        element.isSelected.asObservable()
            .bindTo(cell.rx.isMarked)
            .addDisposableTo(cell.prepareForReuseBag)
        return cell
    }

    dataSource.titleForHeaderInSection = { dataSource, section in
        return dataSource.sectionModels[section].model
    }
}
