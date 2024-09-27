# Heat
This package contains the contracts and UI for interfacing with Heat, an Ethereum-based social music discovery application.

## Music Discovery
The Heat applications allows users to create small groups to share and discover music with. The core mechanism of Heat is 
the time-based selection events users participate in. When a group reaches 4 members, the group will be marked as `active` 
and initialized by introducing its first `SelectionEvent`. SelectionEvents are opportunities for users to propose music they 
find appealing for whatever reason. After 6 days, the SelectionEvent will transition from `Created` to `PendingSelections`. 
At this point, users will view all selections made by the _other_ group members and rank their top 3. Users must submit their
votes within the following 24 hours. The winner from these rankings is awarded reputation based on stats of the songs selected 
across the group. Finally, the event will be moved to `Complete` state and a new SelectionEvent in Created state is generated 
for the group to repeat the process.

## Reputation
Reputation at this point is virtually meaningless, although it could theoretically become something meaningful to music 
enthusiasts as they become established on the application. Users will likely only be allowed in a relatively small number 
of groups and will have reputation decay in some form, at some point. Ultimately, reputation will mostly just be for fun 
until I decide to ever try to make a real mechanism out of it but it does have interesting potential to incentivise broad 
music exploration.

## Heat Frontend
Heat is just going to be a browser-based frontend for now. I'd love to expand it to IOS, though, just for the fun and 
experience of it.
