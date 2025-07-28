PORTNAME=	gershwin-terminal
DISTVERSION=       202507281348
CATEGORIES=	x11 gnustep

MAINTAINER=	jpm820@proton.me
COMMENT=	Gershwin Terminal Emulator for GNUstep
WWW=		https://github.com/gershwin-desktop/gershwin-terminal

LICENSE=	GPLv2 # only

USES=		gnustep iconv
CONFLICTS=	terminal.app
USE_GNUSTEP=	back build

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= 60759a8e96f9145307a7c866a5a82659b347eb73

MAKE_ARGS+=	Terminal_TOOL_LIBS='${ICONV_LIB} -lutil'

.include <bsd.port.mk>
