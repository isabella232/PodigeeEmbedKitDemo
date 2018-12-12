//
//  ViewController.swift
//  PodigeeEmbedKitDemo
//
//  Created by Stefan Trauth on 21.11.18.
//  Copyright © 2018 Podigee. All rights reserved.
//

import UIKit
import PodigeeEmbedKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var coverartImageView: UIImageView!
    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var playbackButton: UIButton!
    
    private var podcastEmbed: PodcastEmbed? {
        didSet {
            updateUI()
        }
    }
    private var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PodigeeEmbedKit.embedDataForPodcastWith(domain: "podcast-news.podigee.io") { (podcastEmbed, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.podcastEmbed = podcastEmbed
        }
    }
    
    private func updateUI() {
        updateCoverart()
        DispatchQueue.main.async {
            self.podcastTitleLabel.text = self.podcastEmbed?.podcast.title
            self.episodeTitle.text = self.podcastEmbed?.episode?.title
        }
    }
    
    private func updateCoverart() {
        DispatchQueue.main.async {
            let coverartWidth = Int(self.coverartImageView.bounds.width)
            guard let coverartUrl = self.podcastEmbed?.episode?.coverartUrlFor(width: coverartWidth) else { return }
            URLSession.shared.dataTask(with: coverartUrl, completionHandler: { (data, response, error) in
                guard let data = data else { return }
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.coverartImageView.image = image
                }
            }).resume()
        }
    }

    @IBAction func togglePlayback(_ sender: UIButton) {
        guard let audioUrl = podcastEmbed?.episode?.media.mp3 else { return }
        player = AVPlayer(url: audioUrl)
        player?.play()
    }
    
}

