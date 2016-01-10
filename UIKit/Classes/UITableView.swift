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

    let UITableViewIndexSearch: String

protocol UITableViewDelegate: UIScrollViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)

    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView

    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)

    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)

    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String
}
protocol UITableViewDataSource: NSObject {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
}
enum UITableViewStyle : Int {
    case Plain
    case Grouped
}

enum UITableViewScrollPosition : Int {
    case None
    case Top
    case Middle
    case Bottom
}

enum UITableViewRowAnimation : Int {
    case Fade
    case Right
    case Left
    case Top
    case Bottom
    case None
    case Middle
    case Automatic = 100
}

class UITableView: UIScrollView {
    convenience override init(frame: CGRect, style: UITableViewStyle) {
    }

    func reloadData() {
        // clear the caches and remove the cells since everything is going to change
        cachedCells.allValues().makeObjectsPerformSelector("removeFromSuperview")
        reusableCells.makeObjectsPerformSelector("removeFromSuperview")
        reusableCells.removeAllObjects()
        cachedCells.removeAllObjects()
        // clear prior selection
        self.selectedRow = nil
        self.highlightedRow = nil
        // trigger the section cache to be repopulated
        self._updateSectionsCache()
        self._setContentSize()
        self.needsReload = false
    }

    func reloadRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
        self.reloadData()
    }

    func numberOfSections() -> Int {
        if dataSourceHas.numberOfSectionsInTableView {
            return self.dataSource.numberOfSectionsInTableView(self)
        }
        else {
            return 1
        }
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return self.dataSource.tableView(self, numberOfRowsInSection: section)
    }

    func indexPathsForRowsInRect(rect: CGRect) -> [AnyObject] {
        // This needs to return the index paths even if the cells don't exist in any caches or are not on screen
        // For now I'm assuming the cells stretch all the way across the view. It's not clear to me if the real
        // implementation gets anal about this or not (haven't tested it).
        self._updateSectionsCacheIfNeeded()
        var results: [AnyObject] = [AnyObject]()
        let numberOfSections: Int = sections.count
        var offset: CGFloat = tableHeaderView ? tableHeaderView.frame.size.height : 0
        for var section = 0; section < numberOfSections; section++ {
            var sectionRecord: UITableViewSection = sections[section]
            var rowHeights: CGFloat = sectionRecord.rowHeights
            let numberOfRows: Int = sectionRecord.numberOfRows
            offset += sectionRecord.headerHeight
            if offset + sectionRecord.rowsHeight >= rect.origin.y {
                for var row = 0; row < numberOfRows; row++ {
                    let height: CGFloat = rowHeights[row]
                    var simpleRowRect: CGRect = CGRectMake(rect.origin.x, offset, rect.size.width, height)
                    if CGRectIntersectsRect(rect, simpleRowRect) {
                        results.append(NSIndexPath(forRow: row, inSection: section))
                    }
                    else if simpleRowRect.origin.y > rect.origin.y + rect.size.height {
                        // don't need to find anything else.. we are past the end
                    }

                    offset += height
                }
            }
            else {
                offset += sectionRecord.rowsHeight
            }
            offset += sectionRecord.footerHeight
        }
        return results
    }

    func indexPathForRowAtPoint(point: CGPoint) -> NSIndexPath {
        var paths: [AnyObject] = self.indexPathsForRowsInRect(CGRectMake(point.x, point.y, 1, 1))
        return (paths.count > 0) ? paths[0] : nil
    }

    func indexPathForCell(cell: UITableViewCell) -> NSIndexPath {
        for index: NSIndexPath in cachedCells.allKeys() {
            if (cachedCells[index] as! String) == cell {
                return index
            }
        }
        return nil
    }

    func indexPathsForVisibleRows() -> [AnyObject] {
        self._layoutTableView()
        var indexes: [AnyObject] = [AnyObject](minimumCapacity: cachedCells.count)
        let bounds: CGRect = self.bounds
        // Special note - it's unclear if UIKit returns these in sorted order. Because we're assuming that visibleCells returns them in order (top-bottom)
        // and visibleCells uses this method, I'm going to make the executive decision here and assume that UIKit probably does return them sorted - since
        // there's nothing warning that they aren't. :)
        for indexPath: NSIndexPath in cachedCells.allKeys().sortedArrayUsingSelector("compare:") {
            if CGRectIntersectsRect(bounds, self.rectForRowAtIndexPath(indexPath)) {
                indexes.append(indexPath)
            }
        }
        return indexes
    }

    func visibleCells() -> [AnyObject] {
        var cells: [AnyObject] = [AnyObject]()
        for index: NSIndexPath in self.indexPathsForVisibleRows {
            var cell: UITableViewCell = self.cellForRowAtIndexPath(index)
            if cell != nil {
                cells.append(cell)
            }
        }
        return cells
    }

    func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell {
        for cell: UITableViewCell in reusableCells {
            if (cell.reuseIdentifier == identifier) {
                var strongCell: UITableViewCell = cell
                // the above strongCell reference seems totally unnecessary, but without it ARC apparently
                // ends up releasing the cell when it's removed on this line even though we're referencing it
                // later in this method by way of the cell variable. I do not like this.
                reusableCells.removeObject(cell)
                strongCell.prepareForReuse()
                return strongCell
            }
        }
        return nil
    }

    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        // this is allowed to return nil if the cell isn't visible and is not restricted to only returning visible cells
        // so this simple call should be good enough.
        return (cachedCells[indexPath] as! String)
    }

    func rectForSection(section: Int) -> CGRect {
        self._updateSectionsCacheIfNeeded()
        return self._CGRectFromVerticalOffset(self._offsetForSection(section), height: sections[section].sectionHeight())
    }

    func rectForHeaderInSection(section: Int) -> CGRect {
        self._updateSectionsCacheIfNeeded()
        return self._CGRectFromVerticalOffset(self._offsetForSection(section), height: sections[section].headerHeight())
    }

    func rectForFooterInSection(section: Int) -> CGRect {
        self._updateSectionsCacheIfNeeded()
        var sectionRecord: UITableViewSection = sections[section]
        var offset: CGFloat = self._offsetForSection(section)
        offset += sectionRecord.headerHeight
        offset += sectionRecord.rowsHeight
        return self._CGRectFromVerticalOffset(offset, height: sectionRecord.footerHeight)
    }

    func rectForRowAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        self._updateSectionsCacheIfNeeded()
        if indexPath && indexPath.section < sections.count {
            var sectionRecord: UITableViewSection = sections[indexPath.section]
            let row: Int = indexPath.row
            if row < sectionRecord.numberOfRows {
                var rowHeights: CGFloat = sectionRecord.rowHeights
                var offset: CGFloat = self._offsetForSection(indexPath.section)
                offset += sectionRecord.headerHeight
                for var currentRow = 0; currentRow < row; currentRow++ {
                    offset += rowHeights[currentRow]
                }
                return self._CGRectFromVerticalOffset(offset, height: rowHeights[row])
            }
        }
        return CGRectZero
    }

    func beginUpdates() {
    }

    func endUpdates() {
    }

    func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        self.reloadData()
    }

    func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        self.reloadData()
    }

    func insertRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
        self.reloadData()
    }
    // not implemented

    func deleteRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
        self.reloadData()
    }
    // not implemented

    func indexPathForSelectedRow() -> NSIndexPath {
        return selectedRow
    }

    func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        if indexPath && indexPath.isEqual(selectedRow) {
            self.cellForRowAtIndexPath(selectedRow).selected = false
            self.selectedRow = nil
        }
    }

    func selectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        // unlike the other methods that I've tested, the real UIKit appears to call reload during selection if the table hasn't been reloaded
        // yet. other methods all appear to rebuild the section cache "on-demand" but don't do a "proper" reload. for the sake of attempting
        // to maintain a similar delegate and dataSource access pattern to the real thing, I'll do it this way here. :)
        self._reloadDataIfNeeded()
        if !selectedRow.isEqual(indexPath) {
            self.deselectRowAtIndexPath(selectedRow, animated: animated)
            self.selectedRow = indexPath
            self.cellForRowAtIndexPath(selectedRow).selected = true
        }
        // I did not verify if the real UIKit will still scroll the selection into view even if the selection itself doesn't change.
        // this behavior was useful for Ostrich and seems harmless enough, so leaving it like this for now.
        self.scrollToRowAtIndexPath(selectedRow, atScrollPosition: scrollPosition, animated: animated)
    }

    func scrollToNearestSelectedRowAtScrollPosition(scrollPosition: UITableViewScrollPosition, animated: Bool) {
        self._scrollRectToVisible(self.rectForRowAtIndexPath(self.indexPathForSelectedRow()), atScrollPosition: scrollPosition, animated: animated)
    }

    func scrollToRowAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
        self._scrollRectToVisible(self.rectForRowAtIndexPath(indexPath), atScrollPosition: scrollPosition, animated: animated)
    }

    func setEditing(editing: Bool, animated animate: Bool) {
        self.editing = editing
    }
    var style: UITableViewStyle {
        get {
            return self.style
        }
    }

    weak var delegate: UITableViewDelegate {
        get {
            return self.delegate
        }
        set {
            super.delegate = newDelegate
            self.delegateHas.heightForRowAtIndexPath = newDelegate.respondsToSelector("tableView:heightForRowAtIndexPath:")
            self.delegateHas.heightForHeaderInSection = newDelegate.respondsToSelector("tableView:heightForHeaderInSection:")
            self.delegateHas.heightForFooterInSection = newDelegate.respondsToSelector("tableView:heightForFooterInSection:")
            self.delegateHas.viewForHeaderInSection = newDelegate.respondsToSelector("tableView:viewForHeaderInSection:")
            self.delegateHas.viewForFooterInSection = newDelegate.respondsToSelector("tableView:viewForFooterInSection:")
            self.delegateHas.willSelectRowAtIndexPath = newDelegate.respondsToSelector("tableView:willSelectRowAtIndexPath:")
            self.delegateHas.didSelectRowAtIndexPath = newDelegate.respondsToSelector("tableView:didSelectRowAtIndexPath:")
            self.delegateHas.willDeselectRowAtIndexPath = newDelegate.respondsToSelector("tableView:willDeselectRowAtIndexPath:")
            self.delegateHas.didDeselectRowAtIndexPath = newDelegate.respondsToSelector("tableView:didDeselectRowAtIndexPath:")
            self.delegateHas.willBeginEditingRowAtIndexPath = newDelegate.respondsToSelector("tableView:willBeginEditingRowAtIndexPath:")
            self.delegateHas.didEndEditingRowAtIndexPath = newDelegate.respondsToSelector("tableView:didEndEditingRowAtIndexPath:")
            self.delegateHas.titleForDeleteConfirmationButtonForRowAtIndexPath = newDelegate.respondsToSelector("tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:")
        }
    }

    weak var dataSource: UITableViewDataSource {
        get {
            return self.dataSource
        }
        set {
            self.dataSource = newSource
            self.dataSourceHas.numberOfSectionsInTableView = dataSource.respondsToSelector("numberOfSectionsInTableView:")
            self.dataSourceHas.titleForHeaderInSection = dataSource.respondsToSelector("tableView:titleForHeaderInSection:")
            self.dataSourceHas.titleForFooterInSection = dataSource.respondsToSelector("tableView:titleForFooterInSection:")
            self.dataSourceHas.commitEditingStyle = dataSource.respondsToSelector("tableView:commitEditingStyle:forRowAtIndexPath:")
            self.dataSourceHas.canEditRowAtIndexPath = dataSource.respondsToSelector("tableView:canEditRowAtIndexPath:")
            self._setNeedsReload()
        }
    }

    var rowHeight: CGFloat {
        get {
            return self.rowHeight
        }
        set {
            self.rowHeight = newHeight
            self.setNeedsLayout()
        }
    }

    var separatorStyle: UITableViewCellSeparatorStyle
    var separatorColor: UIColor
    var tableHeaderView: UIView {
        get {
            return self.tableHeaderView
        }
        set {
            if newHeader != tableHeaderView {
                tableHeaderView.removeFromSuperview()
                self.tableHeaderView = newHeader
                self._setContentSize()
                self.addSubview(tableHeaderView)
            }
        }
    }

    var tableFooterView: UIView {
        get {
            return self.tableFooterView
        }
        set {
            if newFooter != tableFooterView {
                tableFooterView.removeFromSuperview()
                self.tableFooterView = newFooter
                self._setContentSize()
                self.addSubview(tableFooterView)
            }
        }
    }

    var backgroundView: UIView {
        get {
            return self.backgroundView
        }
        set {
            if backgroundView != backgroundView {
                backgroundView.removeFromSuperview()
                self.backgroundView = backgroundView
                self.insertSubview(backgroundView, atIndex: 0)
            }
        }
    }

    var allowsSelection: Bool
    var allowsSelectionDuringEditing: Bool
    // not implemented
    var editing: Bool {
        get {
            return self.editing
        }
        set {
            self.editing = editing
        }
    }

    var sectionHeaderHeight: CGFloat
    var sectionFooterHeight: CGFloat
    var self.needsReload: Bool
    var self.selectedRow: NSIndexPath
    var self.highlightedRow: NSIndexPath
    var self.cachedCells: [NSObject : AnyObject]
    var self.reusableCells: NSMutableSet
    var self.sections: [AnyObject]
    var self.delegateHas: struct{unsignedheightForRowAtIndexPath:1;unsignedheightForHeaderInSection:1;unsignedheightForFooterInSection:1;unsignedviewForHeaderInSection:1;unsignedviewForFooterInSection:1;unsignedwillSelectRowAtIndexPath:1;unsigneddidSelectRowAtIndexPath:1;unsignedwillDeselectRowAtIndexPath:1;unsigneddidDeselectRowAtIndexPath:1;unsignedwillBeginEditingRowAtIndexPath:1;unsigneddidEndEditingRowAtIndexPath:1;unsignedtitleForDeleteConfirmationButtonForRowAtIndexPath:1;}
    var self.dataSourceHas: struct{unsignednumberOfSectionsInTableView:1;unsignedtitleForHeaderInSection:1;unsignedtitleForFooterInSection:1;unsignedcommitEditingStyle:1;unsignedcanEditRowAtIndexPath:1;}


    convenience override init(frame: CGRect) {
        return self(frame: frame, style: .Plain)
    }

    convenience override init(frame: CGRect, style theStyle: UITableViewStyle) {
        if (self.init(frame: frame)) {
            self.style = theStyle
            self.cachedCells = [NSObject : AnyObject]()
            self.sections = [AnyObject]()
            self.reusableCells = NSMutableSet()
            self.separatorColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
            self.separatorStyle = .SingleLine
            self.showsHorizontalScrollIndicator = false
            self.allowsSelection = true
            self.allowsSelectionDuringEditing = false
            self.sectionHeaderHeight = self.sectionFooterHeight = 22
            self.alwaysBounceVertical = true
            if style == .Plain {
                self.backgroundColor = UIColor.whiteColor()
            }
            self._setNeedsReload()
        }
    }

    func _updateSectionsCache() {
        // uses the dataSource to rebuild the cache.
        // if there's no dataSource, this can't do anything else.
        // note that I'm presently caching and hanging on to views and titles for section headers which is something
        // the real UIKit appears to fetch more on-demand than this. so far this has not been a problem.
        // remove all previous section header/footer views
        for previousSectionRecord: UITableViewSection in sections {
            previousSectionRecord.headerView.removeFromSuperview()
            previousSectionRecord.footerView.removeFromSuperview()
        }
        // clear the previous cache
        sections.removeAllObjects()
        if dataSource != nil {
            // compute the heights/offsets of everything
            let defaultRowHeight: CGFloat = rowHeight ?? UITableViewDefaultRowHeight
            let numberOfSections: Int = self.numberOfSections()
            for var section = 0; section < numberOfSections; section++ {
                let numberOfRowsInSection: Int = self.numberOfRowsInSection(section)
                var sectionRecord: UITableViewSection = UITableViewSection()
                sectionRecord.headerTitle = dataSourceHas.titleForHeaderInSection ? self.dataSource.tableView(self, titleForHeaderInSection: section) : nil
                sectionRecord.footerTitle = dataSourceHas.titleForFooterInSection ? self.dataSource.tableView(self, titleForFooterInSection: section) : nil
                sectionRecord.headerHeight = delegateHas.heightForHeaderInSection ? self.delegate.tableView(self, heightForHeaderInSection: section) : sectionHeaderHeight
                sectionRecord.footerHeight = delegateHas.heightForFooterInSection ? self.delegate.tableView(self, heightForFooterInSection: section) : sectionFooterHeight
                sectionRecord.headerView = (sectionRecord.headerHeight > 0 && delegateHas.viewForHeaderInSection) ? self.delegate.tableView(self, viewForHeaderInSection: section) : nil
                sectionRecord.footerView = (sectionRecord.footerHeight > 0 && delegateHas.viewForFooterInSection) ? self.delegate.tableView(self, viewForFooterInSection: section) : nil
                // make a default section header view if there's a title for it and no overriding view
                if !sectionRecord.headerView && sectionRecord.headerHeight > 0 && sectionRecord.headerTitle {
                    sectionRecord.headerView = UITableViewSectionLabel.sectionLabelWithTitle(sectionRecord.headerTitle)
                }
                // make a default section footer view if there's a title for it and no overriding view
                if !sectionRecord.footerView && sectionRecord.footerHeight > 0 && sectionRecord.footerTitle {
                    sectionRecord.footerView = UITableViewSectionLabel.sectionLabelWithTitle(sectionRecord.footerTitle)
                }
                if sectionRecord.headerView {
                    self.addSubview(sectionRecord.headerView)
                }
                else {
                    sectionRecord.headerHeight = 0
                }
                if sectionRecord.footerView {
                    self.addSubview(sectionRecord.footerView)
                }
                else {
                    sectionRecord.footerHeight = 0
                }
                var rowHeights: CGFloat = malloc(numberOfRowsInSection * sizeof())
                var totalRowsHeight: CGFloat = 0
                for var row = 0; row < numberOfRowsInSection; row++ {
                    let rowHeight: CGFloat = delegateHas.heightForRowAtIndexPath ? self.delegate.tableView(self, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: section)) : defaultRowHeight
                    rowHeights[row] = rowHeight
                    totalRowsHeight += rowHeight
                }
                sectionRecord.rowsHeight = totalRowsHeight
                sectionRecord.setNumberOfRows(numberOfRowsInSection, withHeights: rowHeights)
                free(rowHeights)
                sections.append(sectionRecord)
            }
        }
    }

    func _updateSectionsCacheIfNeeded() {
        // if there's a cache already in place, this doesn't do anything,
        // otherwise calls _updateSectionsCache.
        // this is called from _setContentSize and other places that require access
        // to the section caches (mostly for size-related information)
        if sections.count == 0 {
            self._updateSectionsCache()
        }
    }

    func _setContentSize() {
        // first calls _updateSectionsCacheIfNeeded, then sets the scroll view's size
        // taking into account the size of the header, footer, and all rows.
        // should be called by reloadData, setFrame, header/footer setters.
        self._updateSectionsCacheIfNeeded()
        var height: CGFloat = tableHeaderView ? tableHeaderView.frame.size.height : 0
        for section: UITableViewSection in sections {
            height += section.sectionHeight()
        }
        if tableFooterView {
            height += tableFooterView.frame.size.height
        }
        self.contentSize = CGSizeMake(0, height)
    }

    func _layoutTableView() {
        // lays out headers and rows that are visible at the time. this should also do cell
        // dequeuing and keep a list of all existing cells that are visible and those
        // that exist but are not visible and are reusable
        // if there's no section cache, no rows will be laid out but the header/footer will (if any).
        let boundsSize: CGSize = self.bounds.size
        let contentOffset: CGFloat = self.contentOffset.y
        let visibleBounds: CGRect = CGRectMake(0, contentOffset, boundsSize.width, boundsSize.height)
        var tableHeight: CGFloat = 0
        if tableHeaderView {
            var tableHeaderFrame: CGRect = tableHeaderView.frame
            tableHeaderFrame.origin = CGPointZero
            tableHeaderFrame.size.width = boundsSize.width
            self.tableHeaderView.frame = tableHeaderFrame
            tableHeight += tableHeaderFrame.size.height
        }
        // layout sections and rows
        var availableCells: [NSObject : AnyObject] = cachedCells.mutableCopy()
        let numberOfSections: Int = sections.count
        cachedCells.removeAllObjects()
        for var section = 0; section < numberOfSections; section++ {
            var sectionRect: CGRect = self.rectForSection(section)
            tableHeight += sectionRect.size.height
            if CGRectIntersectsRect(sectionRect, visibleBounds) {
                let headerRect: CGRect = self.rectForHeaderInSection(section)
                let footerRect: CGRect = self.rectForFooterInSection(section)
                var sectionRecord: UITableViewSection = sections[section]
                let numberOfRows: Int = sectionRecord.numberOfRows
                if sectionRecord.headerView {
                    sectionRecord.headerView.frame = headerRect
                }
                if sectionRecord.footerView {
                    sectionRecord.footerView.frame = footerRect
                }
                for var row = 0; row < numberOfRows; row++ {
                    var indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
                    var rowRect: CGRect = self.rectForRowAtIndexPath(indexPath)
                    if CGRectIntersectsRect(rowRect, visibleBounds) && rowRect.size.height > 0 {
                        var cell: UITableViewCell = (availableCells[indexPath] as! UITableViewCell) ?? self.dataSource.tableView(self, cellForRowAtIndexPath: indexPath)
                        if cell != nil {
                            cachedCells[indexPath] = cell
                            availableCells.removeObjectForKey(indexPath)
                            cell.highlighted = highlightedRow.isEqual(indexPath)
                            cell.selected = selectedRow.isEqual(indexPath)
                            cell.frame = rowRect
                            cell.backgroundColor = self.backgroundColor
                            cell._setSeparatorStyle(separatorStyle, color: separatorColor)
                            self.addSubview(cell)
                        }
                    }
                }
            }
        }
        // remove old cells, but save off any that might be reusable
        for cell: UITableViewCell in availableCells.allValues() {
            if cell.reuseIdentifier {
                reusableCells.append(cell)
            }
            else {
                cell.removeFromSuperview()
            }
        }
        // non-reusable cells should end up dealloced after at this point, but reusable ones live on in _reusableCells.
        // now make sure that all available (but unused) reusable cells aren't on screen in the visible area.
        // this is done becaue when resizing a table view by shrinking it's height in an animation, it looks better. The reason is that
        // when an animation happens, it sets the frame to the new (shorter) size and thus recalcuates which cells should be visible.
        // If it removed all non-visible cells, then the cells on the bottom of the table view would disappear immediately but before
        // the frame of the table view has actually animated down to the new, shorter size. So the animation is jumpy/ugly because
        // the cells suddenly disappear instead of seemingly animating down and out of view like they should. This tries to leave them
        // on screen as long as possible, but only if they don't get in the way.
        var allCachedCells: [AnyObject] = cachedCells.allValues()
        for cell: UITableViewCell in reusableCells {
            if CGRectIntersectsRect(cell.frame, visibleBounds) && !allCachedCells.containsObject(cell) {
                cell.removeFromSuperview()
            }
        }
        if tableFooterView {
            var tableFooterFrame: CGRect = tableFooterView.frame
            tableFooterFrame.origin = CGPointMake(0, tableHeight)
            tableFooterFrame.size.width = boundsSize.width
            self.tableFooterView.frame = tableFooterFrame
        }
    }

    func _CGRectFromVerticalOffset(offset: CGFloat, height: CGFloat) -> CGRect {
        return CGRectMake(0, offset, self.bounds.size.width, height)
    }

    func _offsetForSection(index: Int) -> CGFloat {
        var offset: CGFloat = tableHeaderView ? tableHeaderView.frame.size.height : 0
        for var s = 0; s < index; s++ {
            offset += sections[s].sectionHeight()
        }
        return offset
    }

    func _reloadDataIfNeeded() {
        if needsReload {
            self.reloadData()
        }
    }

    func _setNeedsReload() {
        self.needsReload = true
        self.setNeedsLayout()
    }

    func layoutSubviews() {
        self.backgroundView.frame = self.bounds
        self._reloadDataIfNeeded()
        self._layoutTableView()
        super.layoutSubviews()
    }

    func setFrame(frame: CGRect) {
        let oldFrame: CGRect = self.frame
        if !CGRectEqualToRect(oldFrame, frame) {
            super.frame = frame
            if oldFrame.size.width != frame.size.width {
                self._updateSectionsCache()
            }
            self._setContentSize()
        }
    }

    func _setUserSelectedRowAtIndexPath(rowToSelect: NSIndexPath) {
        if delegateHas.willSelectRowAtIndexPath {
            rowToSelect = self.delegate.tableView(self, willSelectRowAtIndexPath: rowToSelect)
        }
        var selectedRow: NSIndexPath = self.indexPathForSelectedRow()
        if selectedRow && !selectedRow.isEqual(rowToSelect) {
            var rowToDeselect: NSIndexPath = selectedRow
            if delegateHas.willDeselectRowAtIndexPath {
                rowToDeselect = self.delegate.tableView(self, willDeselectRowAtIndexPath: rowToDeselect)
            }
            self.deselectRowAtIndexPath(rowToDeselect, animated: false)
            if delegateHas.didDeselectRowAtIndexPath {
                self.delegate.tableView(self, didDeselectRowAtIndexPath: rowToDeselect)
            }
        }
        self.selectRowAtIndexPath(rowToSelect, animated: false, scrollPosition: .None)
        if delegateHas.didSelectRowAtIndexPath {
            self.delegate.tableView(self, didSelectRowAtIndexPath: rowToSelect)
        }
    }

    func _scrollRectToVisible(aRect: CGRect, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
        if !CGRectIsNull(aRect) && aRect.size.height > 0 {
            // adjust the rect based on the desired scroll position setting
            switch scrollPosition {
                case .None:
                    break
                case .Top:
                    aRect.size.height = self.bounds.size.height
                case .Middle:
                    aRect.origin.y -= (self.bounds.size.height / 2.0) - aRect.size.height
                    aRect.size.height = self.bounds.size.height
                case .Bottom:
                    aRect.origin.y -= self.bounds.size.height - aRect.size.height
                    aRect.size.height = self.bounds.size.height
            }

            self.scrollRectToVisible(aRect, animated: animated)
        }
    }

    func setEditing(editing: Bool) {
        self.setEditing(editing, animated: false)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !highlightedRow {
            var touch: UITouch = touches.first!
            let location: CGPoint = touch.locationInView(self)
            self.highlightedRow = self(forRowAtPoint: location)
            self.cellForRowAtIndexPath(highlightedRow).highlighted = true
        }
        if highlightedRow {
            self.cellForRowAtIndexPath(highlightedRow).highlighted = false
            self._setUserSelectedRowAtIndexPath(highlightedRow)
            self.highlightedRow = nil
        }
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        if highlightedRow {
            self.cellForRowAtIndexPath(highlightedRow).highlighted = false
            self.highlightedRow = nil
        }
    }

    func _canEditRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        // it's YES by default until the dataSource overrules
        return dataSourceHas.commitEditingStyle && (!dataSourceHas.canEditRowAtIndexPath || dataSource.tableView(self, canEditRowAtIndexPath: indexPath))
    }

    func _beginEditingRowAtIndexPath(indexPath: NSIndexPath) {
        if self._canEditRowAtIndexPath(indexPath) {
            self.editing = true
            if delegateHas.willBeginEditingRowAtIndexPath {
                self.delegate.tableView(self, willBeginEditingRowAtIndexPath: indexPath)
            }
            // deferring this because it presents a modal menu and that's what we do everywhere else in Chameleon
            self.performSelector("_showEditMenuForRowAtIndexPath:", withObject: indexPath, afterDelay: 0)
        }
    }

    func _endEditingRowAtIndexPath(indexPath: NSIndexPath) {
        if self.editing {
            self.editing = false
            if delegateHas.didEndEditingRowAtIndexPath {
                self.delegate.tableView(self, didEndEditingRowAtIndexPath: indexPath)
            }
        }
    }

    func _showEditMenuForRowAtIndexPath(indexPath: NSIndexPath) {
        // re-checking for safety since _showEditMenuForRowAtIndexPath is deferred. this may be overly paranoid.
        if self._canEditRowAtIndexPath(indexPath) {
            var cell: UITableViewCell = self.cellForRowAtIndexPath(indexPath)
            var menuItemTitle: String? = nil
            // fetch the title for the delete menu item
            if delegateHas.titleForDeleteConfirmationButtonForRowAtIndexPath {
                menuItemTitle = self.delegate.tableView(self, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath)
            }
            if menuItemTitle!.characters.count == 0 {
                menuItemTitle = "Delete"
            }
            cell.highlighted = true
            var theItem: NSMenuItem = NSMenuItem(title: menuItemTitle!, action: nil, keyEquivalent: "")
            var menu: NSMenu = NSMenu(title: "")
            menu.autoenablesItems = false
            menu.allowsContextMenuPlugIns = false
            menu.addItem(theItem)
            // calculate the mouse's current position so we can present the menu from there since that's normal OSX behavior
            var mouseLocation: NSPoint = NSEvent.mouseLocation()
            var screenPoint: CGPoint = self.window.screen.convertPoint(NSPointToCGPoint(mouseLocation), fromScreen: nil)
            // modally present a menu with the single delete option on it, if it was selected, then do the delete, otherwise do nothing
            let didSelectItem: Bool = menu.popUpMenuPositioningItem(nil, atLocation: NSPointFromCGPoint(screenPoint), inView: self.window.screen.UIKitView)
            UIApplicationInterruptTouchesInView(nil)
            if didSelectItem {
                dataSource.tableView(self, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
            }
            cell.highlighted = false
        }
        // all done
        self._endEditingRowAtIndexPath(indexPath)
    }

    func rightClick(touch: UITouch, withEvent event: UIEvent) {
        var location: CGPoint = touch.locationInView(self)
        var touchedRow: NSIndexPath = self(forRowAtPoint: location)
        // this is meant to emulate UIKit's swipe-to-delete feature on Mac by way of a right-click menu
        if touchedRow && self._canEditRowAtIndexPath(touchedRow) {
            self._beginEditingRowAtIndexPath(touchedRow)
        }
    }
    // these can come down to use from AppKit if the table view somehow ends up in the responder chain.
    // arrow keys move the selection, page up/down keys scroll the view

    func moveUp(sender: AnyObject) {
        var selection: NSIndexPath = self.indexPathForSelectedRow
        if selection.row > 0 {
            selection = NSIndexPath(forRow: selection.row - 1, inSection: selection.section)
        }
        else if selection.row == 0 && selection.section > 0 {
            for var section = selection.section - 1; section >= 0; section-- {
                let rows: Int = self.numberOfRowsInSection(section)
                if rows > 0 {
                    selection = NSIndexPath(forRow: rows - 1, inSection: section)
                }
            }
        }

        if !selection.isEqual(self.indexPathForSelectedRow) {
            self._setUserSelectedRowAtIndexPath(selection)
            NSCursor.hiddenUntilMouseMoves = true
        }
    }

    func moveDown(sender: AnyObject) {
        var selection: NSIndexPath = self.indexPathForSelectedRow
        if (selection.row + 1) < self.numberOfRowsInSection(selection.section) {
            selection = NSIndexPath(forRow: selection.row + 1, inSection: selection.section)
        }
        else {
            for var section = selection.section + 1; section < self.numberOfSections; section++ {
                let rows: Int = self.numberOfRowsInSection(section)
                if rows > 0 {
                    selection = NSIndexPath(forRow: 0, inSection: section)
                }
            }
        }
        if !selection.isEqual(self.indexPathForSelectedRow) {
            self._setUserSelectedRowAtIndexPath(selection)
            NSCursor.hiddenUntilMouseMoves = true
        }
    }

    func pageUp(sender: AnyObject) {
        var visibleRows: [AnyObject] = self.indexPathsForVisibleRows
        if visibleRows.count > 0 {
            self.scrollToRowAtIndexPath(visibleRows[0], atScrollPosition: .Bottom, animated: true)
            NSCursor.hiddenUntilMouseMoves = true
            self.flashScrollIndicators()
        }
    }

    func pageDown(sender: AnyObject) {
        self.scrollToRowAtIndexPath(self.indexPathsForVisibleRows.lastObject(), atScrollPosition: .Top, animated: true)
        NSCursor.hiddenUntilMouseMoves = true
        self.flashScrollIndicators()
    }
}
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

import AppKit
import AppKit
import AppKit
// http://stackoverflow.com/questions/235120/whats-the-uitableview-index-magnifying-glass-character
    let UITableViewIndexSearch: String = "{search}"

    let self.UITableViewDefaultRowHeight: CGFloat = 43