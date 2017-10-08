//
// Import libraries
//
import UIKit
import PusherSwift
import Alamofire
import GoogleMaps

//
// View controller class
//
class ViewController: UIViewController, GMSMapViewDelegate {
    // Marker on the map
    var locationMarker: GMSMarker!

    // Default starting coordinates
    var longitude = -122.088426
    var latitude  = 37.388064

    // Pusher
    var pusher: Pusher!

    // Map view
    @IBOutlet weak var mapView: GMSMapView!

    //
    // Fires automatically when the view is loaded
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        // Create a GMSCameraPosition that tells the map to display the coordinate
        // at zoom level 15.
        //
        let camera = GMSCameraPosition.camera(withLatitude:latitude, longitude:longitude, zoom:15.0)
        mapView.camera = camera
        mapView.delegate = self

        //
        // Creates a marker in the center of the map.
        //
        locationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        locationMarker.map = mapView

        //
        // Connect to pusher and listen for events
        //
        listenForCoordUpdates()
    }

    //
    // Send a request to the API to simulate GPS coords
    //
    @IBAction func simulateMovement(_ sender: Any) {
        let parameters: Parameters = ["longitude":longitude, "latitude": latitude]

        Alamofire.request("http://localhost:4000/simulate", method: .post, parameters: parameters).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                print("Simulating...")
            case .failure(let error):
                print(error)
            }
        }
    }

    //
    // Connect to pusher and listen for events
    //
    private func listenForCoordUpdates() {
        // Instantiate Pusher
        pusher = Pusher(key: "PUSHER_APP_KEY", options: PusherClientOptions(host: .cluster("PUSHER_APP_CLUSTER")))

        // Subscribe to a Pusher channel
        let channel = pusher.subscribe("mapCoordinates")

        //
        // Listener and callback for the "update" event on the "mapCoordinates"
        // channel on Pusher
        //
        channel.bind(eventName: "update", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                self.longitude = data["longitude"] as! Double
                self.latitude  = data["latitude"] as! Double

                //
                // Update marker position using data from Pusher
                //
                self.locationMarker.position = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                self.mapView.camera = GMSCameraPosition.camera(withTarget: self.locationMarker.position, zoom: 15.0)
            }
        })

        // Connect to pusher
        pusher.connect()
    }
}
