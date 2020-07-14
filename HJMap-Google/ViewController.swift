//
//  ViewController.swift
//  HJMap-Google
//
//  Created by 김희중 on 2020/07/09.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!

    // 추후 marker데이터에 맞게 init 바꿔주면 될 것 같습니다.
  init(position: CLLocationCoordinate2D, name: String) {
    self.position = position
    self.name = name
  }
}

// 37.551630, 126.924496 (홍대)
let kClusterItemCount = 1000
let kCameraLatitude = 37.551630
let kCameraLongitude = 126.924496


class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GMUClusterManagerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, GMUClusterRendererDelegate {
    
    private let cellid = "cellid"
    
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    private var locationManager = CLLocationManager()
    
    lazy var myLocationButton: UIButton = {
        let b = UIButton(type: .system)
        b.addTarget(self, action: #selector(myLocation), for: .touchUpInside)
        b.setImage(UIImage(named: "my_location"), for: .normal)
        b.tintColor = .black
        b.isUserInteractionEnabled = true
        return b
    }()
    
    lazy var switchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = false
        return cv
    }()
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude, longitude: kCameraLongitude, zoom: 15)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.view = mapView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        switchCollectionView.register(switchCell.self, forCellWithReuseIdentifier: cellid)
        
        setupLayouts()
        setMarker()
        
        // 항상 mapview를 화면 일부분에만 놓고싶은 경우,
        // containerview에 mapview를 설정하고 나서 containerview를 해당 view에 addsubview해주어야 한다.
    }
    

    var mapContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    var switchCollectionViewConstraint: NSLayoutConstraint?
    var myLocationButtonConstraint: NSLayoutConstraint?

    fileprivate func setupLayouts() {
        view.addSubview(switchCollectionView)
        view.addSubview(myLocationButton)
        
        switchCollectionViewConstraint = switchCollectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60).first
        myLocationButtonConstraint = myLocationButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 65, rightConstant: 0, widthConstant: 50, heightConstant: 50).first
    }
    
    // MARK: - Private

    /// get my location
    @objc fileprivate func myLocation() {
        guard let lat = self.mapView.myLocation?.coordinate.latitude,
              let lng = self.mapView.myLocation?.coordinate.longitude else { return }

        let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng, zoom: 16.0)
        self.mapView.animate(to: camera)
    }

    fileprivate func setMarker() {
        mapView.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.552468, longitude: 126.923139)
        marker.title = "title"
        marker.snippet = "snippet"
        marker.map = mapView
    }
    
    var infoWindow: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let whiteBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        return view
    }()

    let whiteTriBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()


    let infoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "DMSans-Regular", size: 12)
        lb.textColor = .gray
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    // infoWindow에는 autolayout 적용 불가능.
    @objc fileprivate func setupInfoWindow() {
        mapView.clear()
        customInfoClicked = true
        let width:CGFloat = 143
        let height:CGFloat = 103
        infoWindow.frame = CGRect(x: 0, y: 0, width: width, height: height)
        let mapinfoview = MapinfoView(frame: infoWindow.frame)
        mapinfoview.backgroundColor = .clear
        infoWindow.addSubview(mapinfoview)

        infoWindow.addSubview(whiteBackView)
        whiteBackView.layer.cornerRadius = width * 0.04

        infoWindow.addSubview(whiteTriBackView)

        infoWindow.addSubview(infoLabel)

        whiteBackView.frame = CGRect(x: 0, y: 0, width: width, height: height * 6/7)
        whiteTriBackView.frame = CGRect(x: width * 2/5, y: height * 6/7, width: width * 1/5, height: 1)

        infoLabel.frame = CGRect(x: 12, y: 0, width: 143 - 24, height: height - 12)
        setMarker()
    }
    
    fileprivate func startClustring(custom: Bool) {
        // Set up the cluster manager with default icon generator and renderer.
        var iconGenerator = GMUDefaultClusterIconGenerator()
        if custom {
            /// https://stackoverflow.com/questions/38547622/how-to-implement-gmuclusterrenderer-in-swift
            // custom cluster image --> custom cluster generator
            iconGenerator = MapClusterIconGenerator()
        }

        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        if custom {
            // delegate = self를 해주어야 renderer 관련 function 사용이 가능하고, marker icon(image)를 바꿀 수 있다.
            renderer.delegate = self
        }
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

        // Generate and add random items to the cluster manager.
        generateClusterItems()

        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()

        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func generateClusterItems() {
        let extent = 0.01
        let currentLat = self.mapView.myLocation?.coordinate.latitude
        let currentLng = self.mapView.myLocation?.coordinate.longitude
        for index in 1...kClusterItemCount {
            var lat: Double = 0
            var lng: Double = 0
            if currentLat != nil && currentLng != nil {
                lat = currentLat! + extent * randomScale()
                lng = currentLng! + extent * randomScale()
            }
            else {
                lat = kCameraLatitude + extent * randomScale()
                lng = kCameraLongitude + extent * randomScale()
            }
            let name = "Item \(index)"
            // 원하는 marker데이터에 맞게 POIItem init을 바꿔주고 그거에 맞게 clusterManager에 add 하면 된다.
            let item = POIItem(position: CLLocationCoordinate2D(latitude: lat, longitude: lng), name: name)
            clusterManager.add(item)
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    
    var switchStrings = ["custom info window", "marker clustering", "custom clustering"]
    var imageStrings = ["infoWindow", "cluster", "cluster"]
    var customInfoClicked: Bool = false
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! switchCell
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        cell.switchLabel.text = switchStrings[indexPath.item]
        cell.switchImageView.image = UIImage(named: imageStrings[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if !customInfoClicked {
                // 현재 기본 marker 상태 -> custom info window 보여주고 싶을때
                self.customInfoClicked = true
                self.switchStrings[0] = "default marker settings"
                self.switchCollectionView.reloadData()
                setupInfoWindow()
                
            }
            else {
                // 현재 custom info window 상태 -> 기본 marker 보여주고 싶을때
                self.customInfoClicked = false
                infoWindow.removeFromSuperview()
                self.switchStrings[0] = "custom info window"
                self.switchCollectionView.reloadData()
                setMarker()
            }
            
        }
        
        else if indexPath.item == 1 {
            self.mapView.clear()
            startClustring(custom: false)
        }
            
        else {
            self.mapView.clear()
            startClustring(custom: true)
        }
        
    }
    
    //MARK: - CollectionViewDatasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return switchStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 60)
    }
    



    // MARK: - Location Manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 16.0)

        self.mapView.animate(to: camera)

        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(String(describing: poiItem.name))")
        } else {
          NSLog("Did tap a normal marker")
        }
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("did Tapped info window")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if customInfoClicked {
            // 현재 기본 marker 상태 -> custom info window 보여주고 싶을때
            // 66자 최대
            if let poiItem = marker.userData as? POIItem {
                infoLabel.text = "Testing, \(String(describing: poiItem.name))"
            }
            else {
                infoLabel.text = "메모를 적어주세요"
            }
            return self.infoWindow
        }

        else {
            // 현재 custom info window 상태 -> 기본 marker 보여주고 싶을때
            if let poiItem = marker.userData as? POIItem {
                marker.title = "Testing"
                marker.snippet = "\(String(describing: poiItem.name))"
            }
            return nil
        }
    }
    
    // MARK: - GMUClusterManagerDelegate

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
      let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
        zoom: mapView.camera.zoom + 1)
      let update = GMSCameraUpdate.setCamera(newCamera)
      mapView.moveCamera(update)
      return false
    }
    
    // MARK: - GMUClusterRendererDelegate
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        /// https://stackoverflow.com/questions/43865481/customize-the-marker-on-google-map-with-clusters
        switch object {
        case let item as POIItem:

            let marker = GMSMarker()

            marker.position = item.position
            marker.icon = UIImage(named: "pin")

            return marker
            // 밑에는 아직 잘 안됨.
//        case let staticCluster as GMUStaticCluster:
//            let marker = GMSMarker()
//
//            marker.position = staticCluster.position
//            marker.icon = UIImage(named: "pin")
//
//            return marker
        default:
            return nil
        }
    }

}


class switchCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let switchImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.image = UIImage(named: "")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let switchLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .black
        return label
    }()
    
    var switchImageViewConstraint: NSLayoutConstraint?
    var switchLabelConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        backgroundColor = .white
        
        addSubview(switchImageView)
        addSubview(switchLabel)
        
        switchImageViewConstraint = switchImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 0, widthConstant: 40, heightConstant: 0).first
        switchLabelConstraint = switchLabel.anchor(self.topAnchor, left: switchImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
    }
}
