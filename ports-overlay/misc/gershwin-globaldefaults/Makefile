PORTNAME=       gershwin-globaldefaults
DISTVERSION=       202507281259
CATEGORIES=     misc
MASTER_SITES=   GH

MAINTAINER=     jpm820@proton.me
COMMENT=        Gershwin global defaults for GNUstep under /System
WWW=            https://github.com/gershwin-desktop/gershwin-globaldefaults

LICENSE=        BSD2CLAUSE

USE_GITHUB=     yes
GH_ACCOUNT=     gershwin-desktop
GH_TAGNAME= 8d804bf732b9d7f2f11869f2914efa153c821461

USE_GNUSTEP=    yes

NO_ARCH=        yes
NO_BUILD=       yes

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/GNUstep/System/Library/Preferences/GlobalDefaults
	${INSTALL_DATA} ${WRKSRC}/System/Library/Preferences/GlobalDefaults/*.plist \
		${STAGEDIR}${PREFIX}/GNUstep/System/Library/Preferences/GlobalDefaults
	${MKDIR} ${STAGEDIR}${PREFIX}/GNUstep/System/Library
	${INSTALL_SCRIPT} ${WRKSRC}/System/Library/Gershwin.sh \
		${STAGEDIR}${PREFIX}/GNUstep/System/Library

.include <bsd.port.mk>
