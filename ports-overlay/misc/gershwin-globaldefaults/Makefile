PORTNAME=       gershwin-globaldefaults
DISTVERSION=       202507281348
CATEGORIES=     misc
MASTER_SITES=   GH

MAINTAINER=     jpm820@proton.me
COMMENT=        Gershwin global defaults for GNUstep under /System
WWW=            https://github.com/gershwin-desktop/gershwin-globaldefaults

LICENSE=        BSD2CLAUSE

USE_GITHUB=     yes
GH_ACCOUNT=     gershwin-desktop
GH_TAGNAME= e326dee508c9b23066e84f7c3cf8361eac263582

USE_GNUSTEP=    yes

NO_ARCH=        yes
NO_BUILD=       yes

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/GNUstep/System/Library/Preferences/GlobalDefaults
	${INSTALL_DATA} ${WRKSRC}/System/Library/Preferences/GlobalDefaults/*.plist \
		${STAGEDIR}${PREFIX}/GNUstep/System/Library/Preferences/GlobalDefaults
	${MKDIR} ${STAGEDIR}${PREFIX}/GNUstep/System/Library/Makefiles
	${INSTALL_SCRIPT} ${WRKSRC}/System/Library/Makefiles/Gershwin.sh \
		${STAGEDIR}${PREFIX}/GNUstep/System/Library/Makefiles

.include <bsd.port.mk>
