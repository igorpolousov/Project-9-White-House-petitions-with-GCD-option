//
//  ViewController.swift
//  Project 9, White House petitions with GCD option
//  Day 39
//  Created by Igor Polousov on 03.08.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(findPetition))
       
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            // Поскольку showError содержит объект относящийся к UI нужно будет изменить эту функцию и переместить в главные потоки все UI компоненты
            self?.showError()
        }
          
    }
    
    @objc func findPetition() {
        let ac = UIAlertController(title: "Enter keywords for search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let addAction = UIAlertAction(title: "Find", style: .default) {
            [weak self, weak ac] action in
            // Получили слово из поля textFields
            guard let search = ac?.textFields?[0].text else { return }
            self?.findAndPut(search)
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    // Alert with textField for search function
    func findAndPut(_ search: String) {
        filteredPetitions.removeAll()
        let lowAnswer = search.lowercased()
        
        for petition in petitions {
            let lowPetitionBody = petition.body.lowercased()
            let lowPetitionTitle = petition.title.lowercased()
            if lowPetitionBody.contains(lowAnswer) || lowPetitionTitle.contains(lowAnswer) {
                filteredPetitions.insert(petition, at: 0)
                petitions = filteredPetitions
                tableView.reloadData()
            } else if filteredPetitions.isEmpty {
                notFound()
            }
        }
    }
    // If keyword not found show message
    func notFound() {
        let ac = UIAlertController(title: "Keywords not found", message: "There was no words found; please enter another keywords and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
   // Функция parse  в строке 25 помещена на исполнение в backgroud, запускать UI in background это плохо, поэтому добавлена строка 48, чтобы выполнить действия с UI в главном потоке
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
          // Возвращает загрузку в таблице в главный поток
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

