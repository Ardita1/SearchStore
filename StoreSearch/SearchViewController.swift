//
//  ViewController.swift
//  StoreSearch
//
//  Created by Ardita on 8/28/18.
//  Copyright © 2018 Ardita. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    //MARK: -IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: -Variables
    var searchResults: [SearchResults] = []
    var hasSearched = false
    var isLoading = false
    
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
    }
    
    
    //MARK: - itunesURL
    func iTunesURL(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format:
            "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    
    //MARK: -NumberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    
    //MARK: -CellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cellIdentifier = "SearchResultCell"
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let sppiner = cell.viewWithTag(100) as! UIActivityIndicatorView
            sppiner.startAnimating()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            //            cell.artistNameLabel!.text = searchResult.artistName
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel!.text = "UNKnown"
            } else{
                cell.artistNameLabel!.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            
            
            
        }
        return cell
    }
    
    //MARK: -didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        } else {
            return indexPath
        }
    }
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    //MARK: - perfrom Request
    func performStoreRequest(with url: URL) -> String?{
        
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    //MARK: -JSON parse
    func parse(json: String) ->[String: Any]? {
        guard let  data = json.data(using: .utf8, allowLossyConversion: false)
            else {return nil}
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        } catch{
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    
    //MARK: -parse(dictionary)
    func parse(dictionary: [String:Any]) -> [SearchResults]{
        //1
        guard let array = dictionary["results"] as? [Any] else {
            print("Excepted 'results' array")
            return []
        }
        
        //2
        for resultDict in array {
            //3
            
            
            if let resultDict = resultDict as? [String:Any]{
                
                var searchResult : SearchResults?
                
                if let wrapperType = resultDict["wrapperType"] as? String{
                    switch wrapperType{
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                
                if let result = searchResult{
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    
    //MARK: -parse Track
    func parse(track dictionary: [String:Any]) -> SearchResults {
        let searchResult = SearchResults()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    
    //MARK: -parse AudioBook
    func parse(audiobook dictionary: [String: Any]) -> SearchResults {
        let searchResult = SearchResults()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    //MARK: -parse software
    func parse(software dictionary: [String: Any]) -> SearchResults {
        let searchResult = SearchResults()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    //MARK: -parse Ebook
    func parse(ebook dictionary: [String: Any]) -> SearchResults {
        let searchResult = SearchResults()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }
    
    
    //MARK: -kindForDisplay method
    func kindForDisplay(_ kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
    
}




//MARK: -seachViewControllerDelegate extension
extension SearchViewController: UISearchBarDelegate {
    
    //MARK: -showNetworkError()
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops", message:  "There was an error reading from the iTunes Store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: -searchBarSearchButtonClicked method
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        isLoading = true
        tableView.reloadData()
        
        hasSearched = true
        searchResults = []
        
        
        //NETWORK CODE IN BACKGROUND
        //1
        let queue = DispatchQueue.global()
        
        //2 CODE THAT NEEDS TO RUN IN  THE BACKGROUND
        queue.async {
            let url = self.iTunesURL(searchText: searchBar.text!)
            
            if let jsonString = self.performStoreRequest(with: url),
                let jsonDictionary = self.parse(json: jsonString){
                self.searchResults.sort { (result1, result2) -> Bool in
                    return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
                }
                
                //UPDATE THE USER INTERFACE
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
                return
            }
           
            DispatchQueue.main.async {
                self.showNetworkError()
            }
        }
        
        
        //        //NETWORKING CODE IN MAIN THREAD...
        //        searchResults = []
        //        if !searchBar.text!.isEmpty {
        //            searchBar.resignFirstResponder()
        //
        //            let url = iTunesURL(searchText: searchBar.text!)
        //            print("URL: '\(url)'")
        //
        //            if let jsonString = performStoreRequest(with: url) {
        //                print("Received JSON string '\(jsonString)'")
        //
        //                if let jsonDictionary = parse(json: jsonString) {
        //                    print("Dictionary \(jsonDictionary)")
        //                    searchResults = parse(dictionary: jsonDictionary)
        //                    searchResults.sort { (result1, result2) -> Bool in
        //                        return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
        //                    }
        //                    //END NETWORKING CODE
        //
        //                    isLoading = false
        //                    tableView.reloadData()
        //                    return
        //                }
        //            }
        //            showNetworkError()
        //        }
        //    }
        //
        
        
        //MARK: -position method
        func position(for bar: UIBarPositioning) -> UIBarPosition {
            return .topAttached
        }
    }
}

extension SearchViewController: UITableViewDelegate{
}


extension SearchViewController: UITableViewDataSource{
}
