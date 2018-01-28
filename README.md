テスト用環境
user : pi
Raspbian Nov.2017

IPaddressは各自変更すること。
Vortoj-PacketFilterの en0 を br0 とかにするとよい。

prepare.shを　git clone して他を(?)
`chmod u+x prepare.sh`<br>
`sudo -E ./prepare.sh`

Packet filter実行時は
`sudo -E go run main.go`
