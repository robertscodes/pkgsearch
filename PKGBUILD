# Maintainer: Robert L Box  <robertbox@gmail.com>
pkgname=pkgsearch-helper
pkgver=20250731
pkgrel=1
pkgdesc="Helper script for robertscodes/pkgsearch"
arch=('any')
url="https://github.com/robertscodes/pkgsearch"
license=('GPL3')
depends=()
makedepends=('gnupg' 'wget' 'bash')

source=("pkgsearch-helper.sh"
	'pkgsearch-helper.sh.sig')
	 
	validpgpkeys=('9033C06BC9A1FA15FA9FE88F090603E55AA049C4')
	
	sha256sums=('56d21786b06ba91a52a28c2e5325a6a10ba04212d4e24f538b0beb6da7619d2d'
		   '001e914c828b4caf9d725b37275d2e158917e9b7442ac2f405d41bfce24b5966')	
	
	md5sums=('e9a7b5ada2d02d27de3f8b343e02861b'
		'bf7541d260895df0a38ea60907797f59')

prepare() {
 :
}

package() {
  install -Dm755 pkgsearch-helper.sh "$pkgdir/usr/bin/pkgsearch-helper.sh"
}

validpgpkeys=('9033C06BC9A1FA15FA9FE88F090603E55AA049C4')


