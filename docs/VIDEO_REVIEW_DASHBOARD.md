# Video Review Dashboard Guide

## Open the dashboard

Open the Video Library in Chotto Pathshala and tap the checklist icon in the top toolbar. No Parent PIN is required. The dashboard is intended for an adult reviewer; anyone using the device can open it and change the local review records, so keep the device supervised.

## Review one video

1. Search the title or video ID and choose **Preview video**. The candidate opens in the YouTube app or an external browser, not in the child player.
2. Watch the complete video and return to Chotto Pathshala.
3. Select the correct class band: Playgroup, Nursery, KG, Class 1 or Class 2.
4. Confirm each item only after checking the relevant evidence:
   - Full video is suitable for the selected class and contains no unsafe material.
   - YouTube Made for Kids status is verified from reliable YouTube evidence.
   - You have permission or a suitable licence to include the video in this app.
   - YouTube allows this video to be embedded.
5. Enter the reviewer name and evidence notes. Useful notes include the exact source or API result used for Made for Kids/embedding status and the URL or terms that establish usage permission.
6. Choose **Approve**, **Reject**, or **Save as pending**.

Approve is disabled until all four checks, an age band, a reviewer name and evidence notes are present. If any status cannot be verified, leave it unchecked and save the item as pending. A good title, channel, thumbnail, feed entry, or successful preview is not proof of these requirements.

## What gets saved

Review records are stored on this device in SharedPreferences under `video_library_review_records_v1`. They are restored onto the matching catalogue record after reload. They are not synchronized to other devices, exported to the bundled catalogue, or uploaded to a server. A new device starts with its own pending queue.

## Why an approved video might still not play

There are two independent conditions:

- The individual video must pass the dashboard review.
- The app owner must complete Google's required child-directed YouTube API Client notification and privacy/data setup, then create a build with `YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true`.

The second condition is deliberately not switchable from the dashboard. Do not set the build flag merely to remove a lock; it represents an external Google configuration requirement. The first-use YouTube/app privacy and Terms consent dialog is also separate from Parent PIN or parent approval.

## Current limitation

The dashboard is not protected by a PIN or user account. It is suitable as a simple on-device review tool for the device owner, not as a secure multi-user admin system.
