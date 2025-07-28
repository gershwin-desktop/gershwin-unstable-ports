PORTNAME=	gershwin-workspace
DISTVERSION=       202507281348
CATEGORIES=	deskutils gnustep

MAINTAINER=	jpm820@proton.me
COMMENT=	Gershwin workspace manager
WWW=		https://github.com/gershwin-desktop/gershwin-workspace

LICENSE=	GPLv2

USES=		gnustep
CONFLICTS=	gworkspace
USE_GNUSTEP=	back build
USE_LDCONFIG=	${GNUSTEP_SYSTEM_LIBRARIES}

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= 7ccffe4334f8f16c99af1bd9e62c40ece37b1b66

GNU_CONFIGURE=	yes

pre-configure:
	${RM} -r ${WRKSRC}/GWMetadata

.include <bsd.port.mk>
