//
//  UISearchDisplayController.h
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

class UISearchDisplayController: NSObject {
    convenience override init(searchBar: UISearchBar, contentsController viewController: UIViewController) {
        if (self.init()) {
            self.searchBar = searchBar
            self.viewController = viewController
        }
    }
    weak var delegate: UISearchDisplayDelegate
    var active: Bool {
        get {
            return false
        }
        set {
            self.setActive(active, animated: false)
        }
    }


    func setActive(visible: Bool, animated: Bool) {
    }
    var searchBar: UISearchBar {
        get {
            return self.searchBar
        }
    }

    var searchContentsController: UIViewController {
        get {
            return self.searchContentsController
        }
    }

    var searchResultsTableView: UITableView {
        get {
            return self.searchResultsTableView
        }
    }

    weak var searchResultsDataSource: UITableViewDataSource
    weak var searchResultsDelegate: UITableViewDelegate
    var self.viewController: UIViewController
    var self.tableView: UITableView
    var self.tableViewDataSource: UITableViewDataSource
    var self.tableViewDelegate: UITableViewDelegate


    func dealloc() {
        self.delegate = nil
        self.tableViewDataSource = nil
        self.tableViewDelegate = nil
    }
}
protocol UISearchDisplayDelegate: NSObject {
    // when we start/end showing the search UI
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController)

    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController)

    func searchDisplayControllerWillEndSearch(controller: UISearchDisplayController)

    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController)
    // called when the table is created destroyed, shown or hidden. configure as necessary.

    func searchDisplayController(controller: UISearchDisplayController, didLoadSearchResultsTableView tableView: UITableView)

    func searchDisplayController(controller: UISearchDisplayController, willUnloadSearchResultsTableView tableView: UITableView)
    // called when table is shown/hidden

    func searchDisplayController(controller: UISearchDisplayController, willShowSearchResultsTableView tableView: UITableView)

    func searchDisplayController(controller: UISearchDisplayController, didShowSearchResultsTableView tableView: UITableView)

    func searchDisplayController(controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView)

    func searchDisplayController(controller: UISearchDisplayController, didHideSearchResultsTableView tableView: UITableView)
    // return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods

    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String) -> Bool

    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool
}