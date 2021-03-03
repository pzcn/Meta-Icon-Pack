#!/usr/bin/env bash
if [ "$TRAVIS_PULL_REQUEST" = false ]; then
  if [ "$TRAVIS_TAG" ]; then
    cd $TRAVIS_BUILD_DIR/app/build/outputs/apk/release/

    printf "\n\nGetting tag information\n"
    tagInfo=$(
      curl \
        -H "Authorization: token $GITHUB_API_KEY" \
        "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases/tags/${TRAVIS_TAG}"
    )
    printf "\n\nRelease data: $tagInfo\n"
    releaseId="$(echo "$tagInfo" | jq --compact-output ".id")"

    releaseNameOrg="$(echo "$tagInfo" | jq --compact-output ".tag_name")"
    releaseName=$(echo ${releaseNameOrg} | cut -d "\"" -f 2)

    ln=$"%0D%0A"
    tab=$"%09"

    changes="$(echo "$tagInfo" | jq --compact-output ".body")"
    changes=$(echo ${changes} | cut -d "\"" -f 2)
    defaultChanges="$changes"
    changes=$(echo "${changes//\"\r\n\"/$ln}")
    changes=$(echo "${changes//'\r\n'/$ln}")
    changes=$(echo "${changes//\\r\\n/$ln}")

    repoName=$(echo ${TRAVIS_REPO_SLUG} | cut -d / -f 2)

    printf "\n"

    for apk in $(find *.apk -type f); do
      FILE="$apk"
      printf "\n\nUploading: $FILE ... \n"
      upload=$(
        curl \
          -H "Authorization: token $GITHUB_API_KEY" \
          -H "Content-Type: $(file -b --mime-type $FILE)" \
          --data-binary @$FILE \
          --upload-file $FILE \
          "https://uploads.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${releaseId}/assets?name=$(basename $FILE)&access_token=${GITHUB_API_KEY}"
      )

      printf "\n\nUpload Result: $upload\n"

      url="$(echo "$upload" | jq --compact-output ".browser_download_url")"
      url=$(echo ${url} | cut -d "\"" -f 2)
      url=$(echo "${url//\"\r\n\"/$ln}")
      url=$(echo "${url//'\r\n'/$ln}")
      url=$(echo "${url//\\r\\n/$ln}")

      if [[ ! -z "$url" && "$url" != " " && "$url" != "null" ]]; then
        printf "\nAPK url: $url"
        printf "\n\nSending message to Discord channel…\n"
        message="**Changes:**\n$defaultChanges"
        message+="\n\n**Useful links:**"
        message+="\n* [How to update?](https://github.com/jahirfiquitiva/$repoName/wiki/How-to-update)"
        message+="\n* [Download sample APK]("
        message+="$url"
        message+=")\n* [Donate & support future development](https://jahir.dev/donate)"
        curl -X POST -H 'Content-Type: application/json' -d '{ "embeds": [{ "title": "**New update available! ('"$releaseName"')** 🚀", "description": "'"$message"'", "color": 15844367 }] }' $UPDATE_DISCORD_WEBHOOK

        printf "\n\nFinished uploading APK(s) and sending notifications\n"
      else
        printf "\n\nSkipping notifications because no file was uploaded\n"
      fi
    done
  else
    printf "\n\nSkipping APK(s) upload because this commit does not have a tag\n"
  fi
else
  printf "\n\nSkipping APK(s) upload because this is just a pull request\n"
fi
