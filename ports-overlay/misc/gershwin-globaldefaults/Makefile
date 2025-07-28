PORTNAME=       gershwin-globaldefaults
DISTVERSION=       202507281601
CATEGORIES=     misc
MASTER_SITES=   GH

MAINTAINER=     jpm820@proton.me
COMMENT=        Gershwin global defaults for GNUstep under /System
WWW=            https://github.com/gershwin-desktop/gershwin-globaldefaults

LICENSE=        BSD2CLAUSE

USE_GITHUB=     yes
GH_ACCOUNT=     gershwin-desktop
GH_TAGNAME= 482d5bc9f8b2d82dd41fafd29076b5ebadf11337

USE_GNUSTEP=    yes

NO_ARCH=        yes
NO_BUILD=       yes

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/GNUstep/GlobalDefaults
	${INSTALL_DATA} ${WRKSRC}/GlobalDefaults/*.plist \
		${STAGEDIR}${PREFIX}/GNUstep/GlobalDefaults

.include <bsd.port.mk>
