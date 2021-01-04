# VICO Change Log

All notable changes to this project will be documented in this file.

## Format

Based largely on recommendations on the "Keep a Changelog" site.

For each version, the release date should be indicated, 
and changes should be grouped to describe their impact on the project.

Changes should be categorized as follows:

* "Added" for new features.
* "Changed" for changes in existing functionality.
* "Deprecated" for once-stable features removed in upcoming releases.
* "Removed" for deprecated features removed in this release.
* "Fixed" for any bug fixes.
* "Security" to invite users to upgrade in case of vulnerabilities.
* "Event" for any system events affecting production versions.

## Beta Development

Work began in March 2019.
Goal was to release a Beta version at the start of April.
Many changes made.  Not tracked here.

## First Beta Release

The Beta version was released on 2019-04-02.

## First Beta Updates (most recent at top)

Fixed, 2019-06-20, Update Beta-1-patch-2
* Improved grant/funding citations with guidance from Julie Dietrich, Rebecca Hindin, and Megan Thynge.
* As part of that, incorporated some official "Terms and Conditions" text.

Fixed, 2019-05-09, Update Beta-1-patch-1 
* Fixed text typos.
* Made changes to introductory and disclaimer text for Megan Thynge.
* Removed AmplPy from dependencies on program information page.
* Added comment in program code to mark where parentheses should probably be added.

Event, 2019-04-11, No change.
* Redeployed in the production environment by John Massey after server changes. Fresh Jenkins build.

Added, 2019-04-02, Update Beta-1
* First online version of Visualization Interface for Chesapeake Optimization (VICO).

## Second Beta Release

Important enhancements included the ability to plot two counties' solutions in 
objective space (cost, load) and the ability to compare two points (from same 
county curve or different county curves).  Published in the November 2019 timeframe.

## Second Beta Updates (most recent at top)

Changed, 2020-12-29
* Changed AWS S3 access based on key credentials to access based on the role of the EC2 host.
* Changed feedback contact from Danny Kaufman to Lewis Linker.
