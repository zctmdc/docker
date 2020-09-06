#!/bin/bash
set -x

if [[ -s "$1" ]]; then
  FORCE_UPDATE="$1"
fi
if [[ ! -s "$N2N_TMP_DIR" ]]; then
  N2N_TMP_DIR=/tmp/n2n
fi
if [[ ! -s "$1" ]]; then
  N2N_OPT_DIR=/tmp/bin
fi
cd "/tmp"
rm -rf "$N2N_TMP_DIR"
while [[ ! -d "$N2N_TMP_DIR" ]]; do
  echo "N2N - 正在克隆"
  git clone https://github.com/lucktu/n2n.git
  echo "N2N - 克隆成功"
done

mkdir -p "$N2N_OPT_DIR"

cd "$N2N_TMP_DIR/Linux/" &&
  ls -al | grep "^-" |
  awk '{print $9}' |
    grep "zip" |
    while read line; do
      if [[ "$line" =~ "(" ]]; then
        basename="$(pwd)/$(echo $line | sed -e 's/_v[0-9]\{1,\}\..*//')"
        machine=$(echo "$basename" | sed 's/.*_//')
        unzip -u -d "$basename" "$line"
        file01=$(echo "$line" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/(.*//')
        file02=$(echo "$line" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/.*(//')
        n2nsrcdir="$basename"
        if [[ -d "$basename/static" ]]; then
          n2nsrcdir="$basename/static"
        fi
        for acfile in edge supernode; do
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file01" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file01"
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file02" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file02"
        done
      else
        basename="$(pwd)/$(echo $line | sed -e 's/_v[0-9]\{1,\}\..*//')"
        machine=$(echo "$basename" | sed 's/.*_//')
        unzip -u -d "$basename" "$line"
        file01=$(echo "$line" | sed -e "s/$machine.*//" -e "s/n2n//")"$machine"
        n2nsrcdir="$basename"
        if [[ -d "$basename/static" ]]; then
          n2nsrcdir="$basename/static"
        fi
        for acfile in edge supernode; do
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file01" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file01"
        done
      fi
    done &&
  echo "$($N2N_OPT_DIR/edge_v2_linux_x64 | grep -Eo 'v\..*r[0-9]+')" >"$N2N_OPT_DIR"/n2n_version.txt