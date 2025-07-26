PORTNAME=	gershwin-globaldefaults
DISTVERSION=	202507261230
CATEGORIES=	misc
MASTER_SITES=	GH

MAINTAINER=	jpm820@proton.me
COMMENT=	Gershwin global defaults for GNUstep under /System
WWW=		https://github.com/gershwin-desktop/gershwin-globaldefaults

LICENSE=	BSD2CLAUSE

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME=	1fc6ae772bc71ab540bc363facf5bef4d9e23b9e


NO_ARCH=	yes
NOPREFIX=	yes
NO_BUILD=	yes

do-install:
	${MKDIR} ${STAGEDIR}/System/Library/Preferences/GlobalDefaults
	${INSTALL_DATA} ${WRKSRC}/System/Library/Preferences/GlobalDefaults/*.plist \
		${STAGEDIR}/System/Library/Preferences/GlobalDefaults

.include <bsd.port.mk>
