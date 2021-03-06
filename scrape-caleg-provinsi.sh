#!/bin/sh

if [[ ! -e result/partai.json ]]; then
  curl -k https://infopemilu.kpu.go.id/pileg2019/pencalonan/allparpol.json?_=$(date +%s) > result/partai.json
fi
partai=$(jq '.[].nomorUrut' result/partai.json)

getJson() {
  if curl -k "$1" -o /tmp/temp_$$; then
    if [[ -f /tmp/temp_$$ && $(jq -r '.[]' /tmp/temp_$$ | wc -l) -gt 0 ]]; then
      cat /tmp/temp_$$ >> $2
    else
      echo $1 $2 >> scrape-caleg-provinsi-error.txt
    fi
  fi
}

dapil=$(jq '.[].dapil[].id' result/dapil/dapil_provinsi_wilayah_*.json)
for d in $dapil; do
  for p in $partai; do
    rm -f result/caleg/caleg_provinsi_${d}_${p}.json 2>/dev/null
    getJson https://infopemilu.kpu.go.id/pileg2019/pencalonan/pengajuan-calon/${d}/${p}/dct?_=$(date +%s) result/caleg/caleg_provinsi_${d}_${p}.json
  done
done
