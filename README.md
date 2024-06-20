# Snap Audit Validator

## Usage

```bash
Usage: validate-snap.sh <package name> <audited git commit or tag>                          for the latest NPM version
       validate-snap.sh <package name> <audited git commit or tag> <package version>        for a specific NPM version
```

## Example: Solana Snap

#### 1. Go to the official page for [@solflare-wallet/solana-snap](https://snaps.metamask.io/snap/npm/solflare-wallet/solana-snap/)
![alt text](docs/image.png)

#### 2. Retrieve [the audit report](https://consensys.io/diligence/audits/2023/08/solflare-metamask-snaps-solflare-sui-aptos/)
![alt text](docs/image4.png)

#### 3. Find the audited commit hash (or git tag)
In this case `792fcb2`
![alt text](docs/image2.png)

#### 4. Run the validator against the latest version
```bash
 $ ./validate-snap.sh @solflare-wallet/solana-snap 792fcb2
   Fetching snap manifest for package @solflare-wallet/solana-snap@latest
   Validating published snap manifest
✅ Published shasum matches: hyw8D7jdrDe4FGohp7hjn7miXCk5JVo7yohV5Q3I2io=
   Validating Git URL
✅ Repository URL matches: https://github.com/solflare-wallet/solflare-snap.git
   Validating audited snap manifest
❌ Audited shasum mismatch: KQbUJpORj9R5GsSLwxPvZknSK/eQXIqUcQGpRr6HSEU= != hyw8D7jdrDe4FGohp7hjn7miXCk5JVo7yohV5Q3I2io=

```
**It fails!** 
The latest version is not the audited one, so let's try with earlier versions.

#### 5. Find earlier versions [from NPM](https://www.npmjs.com/package/@solflare-wallet/solana-snap?activeTab=versions).
![alt text](docs/image3.png)

#### 6. Let's try again with `1.0.0`
```bash
 $ ./validate-snap.sh @solflare-wallet/solana-snap 792fcb2 1.0.0
   Fetching snap manifest for package @solflare-wallet/solana-snap@1.0.0
   Validating published snap manifest
✅ Published shasum matches: KQbUJpORj9R5GsSLwxPvZknSK/eQXIqUcQGpRr6HSEU=
   Validating Git URL
💣 Repository URL absent from snap.manifest.json
   Validating audited snap manifest
✅ Audited shasum matches: KQbUJpORj9R5GsSLwxPvZknSK/eQXIqUcQGpRr6HSEU=
   Cleaning up
```
**It works!** 
We have confirmed that the last audited Snap version is `1.0.0`.

## Example 2: [Starknet Snap](https://snaps.metamask.io/snap/npm/consensys/starknet-snap/)

The [audit report by Cobalt](https://drive.google.com/file/d/1Q-Ee7QewVUoAx--x7w_T7WQcvc5MHqVr/view) is not publicly available.

The [audit report by Consensys Diligence](https://consensys.io/diligence/audits/2023/06/metamask/partner-snaps-starknetsnap/) at commit `ec24b00` matches the NPM version `1.7.0`. 

```bash
$ ./validate-snap.sh @consensys/starknet-snap ec24b00 1.7.0
   Fetching snap manifest for package @consensys/starknet-snap@1.7.0
   Validating published snap manifest
✅ Published shasum matches: RHzRmTSlu7cN5ipXCd6AOLx2sy+RasNQRt//U3GblrU=
   Validating Git URL
✅ Repository URL matches: https://github.com/ConsenSys/starknet-snap.git
   Validating audited snap manifest
✅ Audited shasum matches: RHzRmTSlu7cN5ipXCd6AOLx2sy+RasNQRt//U3GblrU=
   Cleaning up
```

The code review ended on June 29 2023 at commit `ec24b00` and the post-audit ended on July 20th 2023 at commit `7231bb7`.

Version `1.7.0` does not include the mitigations applied post-audit. These mitigations may have been included in the `1.8.0-dev-*` version but they were not published as non-dev/non-staging versions. 

```bash
$ npm info --json @consensys/starknet-snap | jq .time
  ...
  "1.7.0": "2023-04-24T09:28:15.962Z",
  "1.7.0-dev-663720e-20230717": "2023-07-17T02:42:43.308Z",
  "1.7.0-dev-32e5293-20230717": "2023-07-17T02:58:00.659Z",
  "1.8.0-dev-32a8388-20230717": "2023-07-17T03:06:23.288Z",
  "1.8.0-dev-0e39bad-20230717": "2023-07-17T03:09:47.250Z",
  "2.0.0-dev-5324859-20230717": "2023-07-17T03:14:02.162Z",
  "2.0.1-dev-1f54b52-20230717": "2023-07-17T03:40:36.370Z",
  ...
  "2.0.1-dev-f879fe0-20230802": "2023-08-02T10:57:32.658Z",
  "2.0.1-staging": "2023-08-02T11:03:08.473Z",
  "2.0.1": "2023-08-02T11:31:12.963Z",
  ...
```

The next official version is `2.0.1` does not match the post-audit commit hash `7231bb7`.
```bash
$ ./validate-snap.sh @consensys/starknet-snap 7231bb7 2.0.1
   Fetching snap manifest for package @consensys/starknet-snap@2.0.1
   Validating published snap manifest
✅ Published shasum matches: Vu0qdZC7rqOId+8QzBNLR3/XdJkdl72183eTR8qT4zE=
   Validating Git URL
✅ Repository URL matches: https://github.com/ConsenSys/starknet-snap.git
   Validating audited snap manifest
❌ Audited shasum mismatch: 8u2ENSdAAY3I536HfY4AM6kvYAkgneqpe6Os0h5UGvY= != Vu0qdZC7rqOId+8QzBNLR3/XdJkdl72183eTR8qT4zE=
```

## Example 3: Kleros Scout Snap

The audited version of [@kleros/scout-snap](https://snaps.metamask.io/snap/npm/kleros/scout-snap/) is `0.5.3` at commit `34d1332` according to [the audit report](https://f8t2x8b2.rocketcdn.me/wp-content/uploads/2023/06/VAR-Kleros-Scout.pdf).

```bash
$ ./validate-snap.sh @kleros/scout-snap 34d1332 0.5.3
   Fetching snap manifest for package @kleros/scout-snap@0.5.3
   Validating published snap manifest
✅ Published shasum matches: DmGgmcwy9MFw1bWIJs6wesNkGIx0Kn0/dFi6Q1AtKwg=
   Validating Git URL
✅ Repository URL matches: https://github.com/kleros/scout-snap.git
   Validating audited snap manifest
✅ Audited shasum matches: DmGgmcwy9MFw1bWIJs6wesNkGIx0Kn0/dFi6Q1AtKwg=
   Cleaning up
```