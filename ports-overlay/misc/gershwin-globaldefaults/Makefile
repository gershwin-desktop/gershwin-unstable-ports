PORTNAME=	gershwin-globaldefaults
DISTVERSION=       202509271954
CATEGORIES=	misc
MASTER_SITES=	GH

MAINTAINER=	joe.maloney@icloud.com
COMMENT=	Gershwin global defaults for GNUstep
WWW=		https://github.com/gershwin-desktop/gershwin-globaldefaults

LICENSE=	BSD2CLAUSE

USES=		gershwin
USE_GERSHWIN=	back build

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= 4ab929e14e09bf029b34814e49c70479775d7b63

NO_ARCH=	yes
NOPREFIX=	yes
NO_BUILD=	yes

do-install:
	${MKDIR} ${STAGEDIR}${GNUSTEP_SYSTEM_ROOT}/Library/Preferences/GlobalDefaults
	${INSTALL_DATA} ${WRKSRC}${GNUSTEP_SYSTEM_ROOT}/Library/Preferences/GlobalDefaults/*.plist \
		${STAGEDIR}${GNUSTEP_SYSTEM_ROOT}/Library/Preferences/GlobalDefaults

.include <bsd.port.mk>
