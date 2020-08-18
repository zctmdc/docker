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
  echo "N2N - 克隆完毕"
done

mkdir -p "$N2N_OPT_DIR"

replaseKV='
el-le
amd64-x64
386-x86
'

cd "$N2N_TMP_DIR/Linux/" &&
  ls -al | grep "^-" |
  awk '{print $9}' |
    grep "zip" |
    while read line_src_file; do
      if [[ "$line_src_file" =~ "(" ]]; then
        basename="$(pwd)/$(echo $line_src_file | sed -e 's/_v[0-9]\{1,\}\..*//')"
        machine=$(echo "$basename" | sed 's/.*_//')
        file01=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/(.*//')
        file02=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/.*(//')
        n2nsrcdir="$basename"
        unzip -u -d "$basename" "$line_src_file"
        if [[ -d "$basename/static" ]]; then
          n2nsrcdir="$basename/static"
        fi
        for acfile in edge supernode; do
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file01" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file01"
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file02" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file02"
          for line_rep in ${replaseKV}; do
            line_rep_k="${line_rep%-*}"
            line_rep_v="${line_rep#*-}"
            if [[ "$file01" == *"${line_rep_k}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file01"
              to_file="$N2N_OPT_DIR/$acfile${file01%%${line_rep_k}}${line_rep_v}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
            if [[ "$file01" == *"${line_rep_v}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file01"
              to_file="$N2N_OPT_DIR/$acfile${file01%%${line_rep_v}}${line_rep_k}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
            if [[ "$file02" == *"${line_rep_k}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file02"
              to_file="$N2N_OPT_DIR/$acfile${file02%%${line_rep_k}}${line_rep_v}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
            if [[ "$file02" == *"${line_rep_v}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file02"
              to_file="$N2N_OPT_DIR/$acfile${file02%%${line_rep_v}}${line_rep_k}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
          done
        done
      else
        basename="$(pwd)/$(echo $line_src_file | sed -e 's/_v[0-9]\{1,\}\..*//')"
        machine=$(echo "$basename" | sed 's/.*_//')
        unzip -u -d "$basename" "$line_src_file"
        file01=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")"$machine"
        echo "file01=$file01"
        n2nsrcdir="$basename"
        if [[ -d "$basename/static" ]]; then
          n2nsrcdir="$basename/static"
        fi
        for acfile in edge supernode; do
          cp "$n2nsrcdir/$acfile" "$N2N_OPT_DIR/$acfile$file01" &&
            chmod 0755 "$N2N_OPT_DIR/$acfile$file01"
          for line_rep in ${replaseKV}; do
            echo "line_rep=${line_rep}"
            line_rep_k="${line_rep%-*}"
            line_rep_v="${line_rep#*-}"
            echo "$file01 --- ${line_rep_k} --- ${line_rep_v}"

            if [[ "$file01" == *"${line_rep_k}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file01"
              to_file="$N2N_OPT_DIR/$acfile${file01%%${line_rep_k}}${line_rep_v}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
            if [[ "$file01" == *"${line_rep_v}" ]]; then
              src_file="$N2N_OPT_DIR/$acfile$file01"
              to_file="$N2N_OPT_DIR/$acfile${file01%%${line_rep_v}}${line_rep_k}"
              cp -f "${src_file}" "${to_file}" &&
                chmod 0755 "${to_file}"
            fi
          done
        done
      fi
    done &&
  echo "$($N2N_OPT_DIR/edge_v2_linux_x64 | grep -Eo 'v\..*r[0-9]+')" >"$N2N_OPT_DIR"/n2n_version.txt &&
  /usr/local/sbin/qshell-linux-x64-v2.4.2 qupload ~/.qshell/qupload.conf
