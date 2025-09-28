PORTNAME=	gershwin-workspace
DISTVERSION=       202509271954
CATEGORIES=	deskutils gnustep

MAINTAINER=	joe.maloney@icloud.com
COMMENT=	Gershwin workspace manager
WWW=		https://github.com/gershwin-desktop/gershwin-workspace

LICENSE=	GPLv2

USES=		gershwin
CONFLICTS=	gworkspace
USE_GERSHWIN=	back build
USE_LDCONFIG=	${GNUSTEP_SYSTEM_LIBRARIES}

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= 85e6ad0119a6d130de4ec4ba7c22aa30123b6837

GNU_CONFIGURE=	yes

pre-configure:
	${RM} -r ${WRKSRC}/GWMetadata

.include <bsd.port.mk>
