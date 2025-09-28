PORTNAME=	gershwin
PORTVERSION=       202509271954
CATEGORIES=	x11 gnustep
MASTER_SITES=	# empty
DISTFILES=	# empty

MAINTAINER=	joe.maloney@icloud.com
COMMENT=	GNUstep Gershwin desktop environment meta port
WWW=		https://github.com/gershwin-desktop/gershwin-desktop

LICENSE=	BSD3CLAUSE

RUN_DEPENDS=	gershwin-globaldefaults>0:misc/gershwin-globaldefaults \
		gershwin-tools-make>0:devel/gershwin-tools-make \
		gershwin-libs-base>0:lang/gershwin-libs-base \
		gershwin-libs-gui>0:x11-toolkits/gershwin-libs-gui \
		gershwin-libs-back>0:x11-toolkits/gershwin-libs-back \
		gershwin-workspace>0:deskutils/gershwin-workspace \
		gershwin-rik-theme>0:x11-themes/gershwin-rik-theme \
		gershwin-systempreferences>0:deskutils/gershwin-systempreferences \
		xorg-fonts-truetype>0:x11-fonts/xorg-fonts-truetype

USES=		metaport

NO_ARCH=	yes
NO_BUILD=	yes

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/share/doc/${PORTNAME}
	${ECHO_CMD} "This is a meta port for the Gershwin desktop environment." > \
		${STAGEDIR}${PREFIX}/share/doc/${PORTNAME}/README

.include <bsd.port.mk>
