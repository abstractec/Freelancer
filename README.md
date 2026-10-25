# Freelancer

Freelancer is a small SwiftUI app for tracking freelance work: clients, projects, tasks, billable time, and invoices.

You must accept full responsibility for using this software to manage finances. This is a research project, not a production-ready product. It does not replace accounting software, and it does not file taxes or send invoices for you.

## What you can do

- Keep a sidebar of clients, with projects nested under each client.
- Track tasks for a client or a project, and see every task in one list.
- Record billables on a project as either time (a rate plus a start and end) or a fixed cost (an amount, currency, and a start and end).
- Build an invoice by choosing open billables and an optional tax. Payment terms on the client set the due date, and past-due invoices are marked in the sidebar.
- Export an invoice to PDF. The page uses your company name, address, logo, and bank details, plus the client address.

On the Mac, company details, rates, and taxes live in **Settings** (the app’s Settings window). On iPhone and iPad, open **Settings** from the gear in the sidebar.

## Requirements

- Xcode 16 or later
- macOS 14 or later, or iOS 17 or later
- A free Apple ID is enough to run it locally

Open `Freelancer.xcodeproj`, select the **Freelancer** scheme, choose My Mac or an iOS destination, and run.

The same target builds for macOS, iPhone, and iPad. The bundle identifier is `com.abstractec.Freelancer`.

## Data storage

The app stores everything in a **local SwiftData** database on that device. A free Personal Team cannot enable iCloud, so sync between a Mac and an iPhone is off unless you turn it on as below.

Company settings and the invoice logo are part of that store (`UserSettings`).

### Turning on Mac and iOS sync

CloudKit sync needs a **paid Apple Developer Program** membership. Then:

1. In Xcode, under Signing & Capabilities, add **iCloud** with **CloudKit**, using the container `iCloud.com.abstractec.Freelancer`.
2. Add the matching CloudKit entitlement keys to `Freelancer/Freelancer.entitlements` and `Freelancer/Freelancer-iOS.entitlements`.
3. Set `cloudKitSyncEnabled = true` in `Freelancer/FreelancerApp.swift`.
4. Sign in with the same Apple ID on each device and leave the app running long enough for the first sync.

If the CloudKit store cannot be opened, the app falls back to the local store and prints the error.
