//
//  UISearchBar.h
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

class UISearchBar: UIView {
    var text: String {
        get {
            return searchField.text!
        }
        set {
            self.searchField.text = text
        }
    }

    weak var delegate: UISearchBarDelegate
    var showsCancelButton: Bool
    var placeholder: String
    var self.searchField: UITextField


    convenience override init(frame: CGRect) {
        if (self.init(frame: frame)) {
            self.searchField = UITextField(frame: frame)
            self.addSubview(searchField)
        }
    }

    func dealloc() {
        self.delegate = nil
    }
}
protocol UISearchBarDelegate: NSObject {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool

    func searchBarTextDidBeginEditing(searchBar: UISearchBar)

    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool

    func searchBarTextDidEndEditing(searchBar: UISearchBar)

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)

    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool

    func searchBarSearchButtonClicked(searchBar: UISearchBar)

    func searchBarBookmarkButtonClicked(searchBar: UISearchBar)

    func searchBarCancelButtonClicked(searchBar: UISearchBar)

    func searchBarResultsListButtonClicked(searchBar: UISearchBar)

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
}