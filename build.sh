#!/bin/sh

MODULE=quarkdrivewebdav
VERSION=$(cat ./quarkdrivewebdav/version|sed -n 1p)
TITLE="quarkdrive-webdav"
DESCRIPTION="quarkdrive-webdav"
HOME_URL=Module_quarkdrivewebdav.asp
CURR_PATH="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"




build_pkg() {

	echo hnd > ./quarkdrivewebdav/.valid
	echo "quarkdrivewebdav.tar.gz"
	tar -zcvf ${CURR_PATH}/quarkdrivewebdav.tar.gz quarkdrivewebdav >/dev/null
	

}





pack(){

	build_pkg

}

make(){
	
	pack
	
}


make



