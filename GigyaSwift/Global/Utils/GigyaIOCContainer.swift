//
//  GigyaIOCContainer.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 10/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class GigyaIOCContainer<T: GigyaAccountProtocol> {
    let container: IOCContainer

    init() {
        self.container = IOCContainer()

        registerDependencies()
    }

    private func registerDependencies() {
        container.register(service: GigyaConfig.self, isSingleton: true) { _ in GigyaConfig() }

        container.register(service: NetworkAdapterProtocol.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return NetworkAdapter(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: ApiServiceProtocol.self) { resolver in
            let sessionService = resolver.resolve(SessionServiceProtocol.self)

            return ApiService(with: resolver.resolve(NetworkAdapterProtocol.self)!, session: sessionService!)
        }

        container.register(service: KeychainStorageFactory.self) { resolver in
            let plistFactory = resolver.resolve(PlistConfigFactory.self)

            return KeychainStorageFactory(plistFactory: plistFactory!)
        }

        container.register(service: SessionServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let keychainHelper = resolver.resolve(KeychainStorageFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return SessionService(config: config!, persistenceService: persistenceService!, accountService: accountService!, keychainHelper: keychainHelper!)
        }

        container.register(service: BiometricServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return BiometricService(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: BiometricServiceInternalProtocol.self, isSingleton: true) { resolver in
            let biometric = resolver.resolve(BiometricServiceProtocol.self)

            return biometric as! BiometricServiceInternalProtocol
        }

        container.register(service: SocialProvidersManagerProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return SocialProvidersManager(sessionService: sessionService!, config: config!, persistenceService: persistenceService!)
        }

        container.register(service: BusinessApiServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let providerFactory = resolver.resolve(SocialProvidersManagerProtocol.self)
            let interruptionsHandler = resolver.resolve(InterruptionResolverFactoryProtocol.self)
            let biometricService = resolver.resolve(BiometricServiceInternalProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return BusinessApiService(config: config!,
                                      persistenceService: persistenceService!,
                                      apiService: apiService!,
                                      sessionService: sessionService!,
                                      accountService: accountService!,
                                      providerFactory: providerFactory!,
                                      interruptionsHandler: interruptionsHandler!,
                                      biometricService: biometricService!)
        }

        container.register(service: AccountServiceProtocol.self, isSingleton: true) { _ in
            return AccountService()
        }

        container.register(service: PersistenceService.self, isSingleton: true) { _ in
            return PersistenceService()
        }

        container.register(service: InterruptionResolverFactoryProtocol.self) { _ in
            return InterruptionResolverFactory()
        }

        container.register(service: PlistConfigFactory.self) { _ in
            return PlistConfigFactory()
        }

        container.register(service: GigyaCore<T>.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)
            let biometricService = resolver.resolve(BiometricServiceProtocol.self)
            let interruptionResolver = resolver.resolve(InterruptionResolverFactoryProtocol.self)
            let plistFactory = resolver.resolve(PlistConfigFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return GigyaCore(config: config!,
                             persistenceService: persistenceService!,
                             businessApiService: businessService!,
                             sessionService: sessionService!,
                             interruptionResolver: interruptionResolver!,
                             biometric: biometricService!,
                             plistFactory: plistFactory!)
        }
    }
}