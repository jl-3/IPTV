//
//  playerViewController.swift
//  TVTestApp
//
//  Created by Iain Munro on 01/04/2017.
//  Copyright © 2017 Iain Munro. All rights reserved.
//

import Foundation

class playerViewController : UIViewController, UITableViewDelegate, VLCMediaPlayerDelegate {
    
    let mp = VLCMediaPlayer()
    var dataSource: ChannelTableViewDataSource?
    
    @IBOutlet weak var channelsTableView: UITableView!
    @IBOutlet var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mp.drawable = videoView
        view.bringSubview(toFront: channelsTableView)
        
        self.dataSource = ChannelTableViewDataSource(tableView: self.channelsTableView)
        channelsTableView.dataSource = self.dataSource
        channelsTableView.delegate = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(openMenu(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        //TODO: Make it remember the last channel
        play((dataSource?.channels[0].url)!)
    }
    
    func play(_ url:URL) {
        mp.media = VLCMedia(url: url)
        mp.delegate = self
        mp.media.addOptions(["network-caching": 3000, "clock-synchro": 0, "high-priority": true])
        mp.play()
        closeMenu(gesture: UIGestureRecognizer(target: nil, action: nil))
    }
    
    // Called after the user changes the selection.
    @available(tvOS 2.0, *)
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let channel = dataSource?.channels[indexPath.row] {
            play(channel.url)
        }
    }
    
    func closeMenu(gesture: UIGestureRecognizer) {
        UIView.animate(withDuration: 1, animations: {
            self.channelsTableView.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width / 3,height: UIScreen.main.bounds.size.height)
            self.channelsTableView.layoutIfNeeded()
        })
    }
    
    func openMenu(gesture: UIGestureRecognizer) {
        UIView.animate(withDuration: 1, animations: {
            self.channelsTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 3,height: UIScreen.main.bounds.size.height)
            self.channelsTableView.layoutIfNeeded()
        })
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        switch mp.state {
        case .error:
            fallthrough
        case .ended:
            fallthrough
        case .stopped:
            self.mp.play()
        case .paused:
            print("paused")
            break
        case .playing:
            print("playing")
            break
        case .buffering:
            print("buffering")
            break
        default:
            break
        }
    }
    
}
