#!/bin/bash
# set -x
if [[ -d $N2N_TMP_DIR ]]; then
  cd $N2N_TMP_DIR && git pull
else
  git clone https://github.com/lucktu/n2n.git $N2N_TMP_DIR
fi

replaseKV='
el-le
amd64-x64
386-x86
i386-x86
'

extract_n2n() {
  echo ----------------------------------------------------------------
  cd $1 &&
    ls -al | grep "^-" |
    awk '{print $9}' |
      grep "zip" |
      while read line_src_file; do
        dir_name="$(echo $line_src_file | sed 's/\.zip//')"
        n2nsrcdir="$(pwd)/$(echo $line_src_file | sed -e 's/_v[0-9]\{1,\}\..*//')"
        machine=$(echo "$n2nsrcdir" | sed 's/.*_//')
        rm -rf "$(pwd)/$dir_name" "$n2nsrcdir"
        unzip -o -d "$(pwd)/$dir_name" "$line_src_file"
        if [[ -d "$(pwd)/$dir_name/$dir_name" ]]; then
          mv -f "$(pwd)/$dir_name/$dir_name/"* "$(pwd)/$dir_name/"
          rm -rf "$(pwd)/$dir_name/$dir_name/"
        fi
        mv -f "$(pwd)/$dir_name" "$n2nsrcdir"
        if [[ -d "$n2nsrcdir/static" ]]; then
          n2nsrcdir="$n2nsrcdir/static"
        fi
        if [[ "$line_src_file" =~ "(" ]]; then
          file01=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/(.*//')
          file02=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")$(echo "$machine" | sed -e 's/)//' -e 's/.*(//')
          file_n2ns="$file01 $file02"
        else
          file01=$(echo "$line_src_file" | sed -e "s/$machine.*//" -e "s/n2n//")"$machine"
          file_n2ns="$file01"
        fi
        for file_n2n in $file_n2ns; do
          for acfile in edge supernode; do
            src_file="$n2nsrcdir/$acfile"
            to_file="$N2N_OPT_DIR/$acfile$file_n2n"
            chmod 0755 "${src_file}" && cp "${src_file}" "${to_file}"
            for line_rep in ${replaseKV}; do
              line_rep_k="${line_rep%-*}"
              line_rep_v="${line_rep#*-}"
              if [[ "${to_file}" == *"${line_rep_k}" ]]; then
                o_to_file="${to_file%%${line_rep_k}}${line_rep_v}"
                cp -f "${src_file}" "${o_to_file}"
              fi
              if [[ "${to_file}" == *"${line_rep_v}" ]]; then
                o_to_file="${to_file%%${line_rep_v}}${line_rep_k}"
                cp -f "${src_file}" "${o_to_file}"
              fi
            done
          done
        done
      done
}

extract_n2n "$N2N_TMP_DIR/Linux/"
extract_n2n "$N2N_TMP_DIR/Linux/n2n_v1"
extract_n2n "$N2N_TMP_DIR/Linux/n2n_v2"
extract_n2n "$N2N_TMP_DIR/Linux/n2n_v2s"

echo ################################################################

n2n_version="$(ls $N2N_TMP_DIR/Linux/ | grep n2n_v3_linux_x64 | grep -oP "(\d+\.){2}\d+")" &&
  echo "n2n_version : v${n2n_version}" &&
  echo v${n2n_version} >"$N2N_OPT_DIR"/n2n_version.txt
