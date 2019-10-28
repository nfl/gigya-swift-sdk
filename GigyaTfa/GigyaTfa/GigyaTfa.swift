//
//  GigyaTfa.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

public class GigyaTfa {

    public static let shared: GigyaTfa = GigyaTfa()

    private let pushService: PushNotificationsServiceProtocol

    init() {
        self.pushService = PushNotificationsService()
    }

    // MARK: Push TFA - Available in iOS 10+

    /**
     Recive Push

     - Parameter userInfo:   dictionary from didReceiveRemoteNotification.
     - Parameter completion:  Completion from didReceiveRemoteNotification.
     */

    @available(iOS 10.0, *)
    public func recivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        pushService.onRecivePush(userInfo: userInfo, completion: completion)
    }

    /**
     Foreground notification receive

     - Parameter data:   dictionary of message from didReceive:remoteMessage.
     */

    public func foregrundNotification(with data: [AnyHashable : Any]) {
        let title = data["title"] as? String ?? ""
        let body = data["body"] as? String ?? ""
        let gigyaAssertion = data["gigyaAssertion"] as? String ?? ""

        GeneralUtils.showNotification(title: title, body: body, id: gigyaAssertion, userInfo: data)
    }

    /**
     Save push token ( from FCM )

     - Parameter key: FCM Key.
     */

    @available(iOS 10.0, *)
    public func updatePushToken(key: String) {
        pushService.savePushKey(key: key)
    }

    /**
     Request to Opt-In to push Two Factor Authentication.
     This is the first of two stages of the Opt-In process.

      - Parameter completion: Request response.
      */

    public func OptiInPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushService.optInToPushTfa(completion: completion)
    }

    /**
     Request to Opt-In to push Two Factor Authentication.
     This is the first of two stages of the Opt-In process.

      - Parameter response: `UNNotificationResponse` from a tapped notification .
      */

    public func verifyPushTfa(with response: UNNotificationResponse) {
        pushService.verifyPushTfa(response: response)
    }
}
