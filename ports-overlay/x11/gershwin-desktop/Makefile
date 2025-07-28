PORTNAME=	gershwin-desktop
PORTVERSION=       202507281348
CATEGORIES=	x11 gnustep
MASTER_SITES=	# empty
DISTFILES=	# empty

MAINTAINER=	jpm820@proton.me
COMMENT=	GNUstep Gershwin desktop environment meta port
WWW=		https://github.com/gershwin-desktop/gershwin-desktop

LICENSE=	BSD3CLAUSE

RUN_DEPENDS=	gershwin-workspace>0:deskutils/gershwin-workspace \
		gershwin-rik-theme>0:x11-themes/gershwin-rik-theme \
		gershwin-systempreferences>0:deskutils/gershwin-systempreferences \
		gershwin-terminal>0:x11/gershwin-terminal \
		gershwin-textedit>0:deskutils/gershwin-textedit

USES=		metaport

NO_ARCH=	yes
NO_BUILD=	yes

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/share/doc/${PORTNAME}
	${ECHO_CMD} "This is a meta port for the Gershwin desktop environment." > \
		${STAGEDIR}${PREFIX}/share/doc/${PORTNAME}/README

.include <bsd.port.mk>
