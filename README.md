# Freelancer

Freelancer is an open source application to handle invoices, tasks and projects for a freelancing operation.

You must accept full responsibility for using this software to manage finances. This is a research project, not a production ready product.

## Platforms

The same app target builds for **macOS**, **iPhone**, and **iPad**.

Bundle identifier: `com.abstractec.Freelancer`.

## Data storage

By default the app uses a **local SwiftData** store on each device (required for free/Personal Team signing — Personal Teams cannot use the iCloud capability).

### Enabling Mac ↔ iOS sync later

iCloud CloudKit sync needs a **paid Apple Developer Program** membership ($99/year). Then:

1. In Xcode → Signing & Capabilities, add **iCloud** with **CloudKit**, container `iCloud.com.abstractec.Freelancer`.
2. Put the CloudKit keys back in `Freelancer.entitlements` / `Freelancer-iOS.entitlements`.
3. Set `cloudKitSyncEnabled = true` in `FreelancerApp.swift`.
4. Sign into the **same Apple ID** on each device and allow time for the first sync.

Company settings and the invoice logo already live in SwiftData (`UserSettings`), so they will sync once CloudKit is enabled.
