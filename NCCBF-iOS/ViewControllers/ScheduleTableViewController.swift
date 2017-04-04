//
//  ScheduleTableViewController.swift
//  NCCBF-iOS
//
//  Created by Keita Ito on 3/22/17.
//  Copyright © 2017 Keita Ito. All rights reserved.
//

import UIKit
import CoreData

class ScheduleTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    
    var context: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<Event>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        setupTableView()
        setupUI()
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.ReuseIdentifier, for: indexPath) as! ScheduleTableViewCell

        guard let event = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Event object is not found.")
        }
        
        cell.configure(with: event)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Event object is not found.")
        }
        guard let vc = UIStoryboard.instantiateViewController(withIdentifier: "EventDetailsViewController") as? EventDetailsViewController else {
            return
        }
        
        vc.eventDetails = EventDetailsViewModel(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        guard let scheduleDateSegment = ScheduleDateSegment(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        fetchedResultsController?.fetchRequest.predicate = scheduleDateSegment.predicate
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        title = "Schedule"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func initializeFetchedResultsController() {
        guard let context = context else { fatalError("context is nil.") }
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = ScheduleDateSegment(rawValue: dateSegmentedControl.selectedSegmentIndex)?.predicate
        let startAtSort = NSSortDescriptor(key: "startAt", ascending: true)
        let endAtSort = NSSortDescriptor(key: "endAt", ascending: true)
        request.sortDescriptors = [startAtSort, endAtSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }
}