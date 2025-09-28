PORTNAME=	libs-gui
DISTVERSION=       202509271954
CATEGORIES=	x11-toolkits gnustep
PKGNAMEPREFIX=	gershwin-

MAINTAINER=	joe.maloney@icloud.com
COMMENT=	GNUstep GUI library
WWW=		http://www.gnustep.org/

LICENSE=	GPLv3 LGPL3
LICENSE_COMB=	multi

LIB_DEPENDS+=	libtiff.so:graphics/tiff \
		libpng.so:graphics/png \
		libgif.so:graphics/giflib \
		libicui18n.so:devel/icu \
		libsndfile.so:audio/libsndfile \
		libao.so:audio/libao \
		libflite.so:audio/flite

USES=		gershwin jpeg pkgconfig xorg
CONFLICTS=	gnustep-gui
USE_GERSHWIN=	base build
USE_XORG=	x11 xt

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= 53afce3d27e238cd13739cdfa64f657e0ee69c9d

GNU_CONFIGURE=	yes

MAKE_FLAGS+=	OPTFLAG="${CFLAGS}"

PLIST_SUB+=	BASEVERSION=${PORTVERSION:C/[.][0-9]*$//1}

OPTIONS_DEFINE=	DOCS CUPS ASPELL
OPTIONS_DEFAULT=	ASPELL CUPS
OPTIONS_SUB=	yes

DOCS_BUILD_DEPENDS=	texi2html:textproc/texi2html \
			texi2pdf:print/texinfo

CUPS_CONFIGURE_ENABLE=		cups
CUPS_LIB_DEPENDS+=	libcups.so:print/cups
ASPELL_LIB_DEPENDS=	libaspell.so:textproc/aspell
ASPELL_CONFIGURE_ENABLE=	aspell

USE_LDCONFIG=	${GNUSTEP_SYSTEM_LIBRARIES}

post-patch:
	${REINPLACE_CMD} -e "s|doc=no|doc=yes|" ${WRKSRC}/GNUmakefile

pre-configure:
.for file in config.guess config.sub install-sh
	@${CP} ${GNUSTEP_SYSTEM_ROOT}/Library/Makefiles/${file} ${WRKSRC}
.endfor

post-install-DOCS-off:
	@${FIND} -d ${STAGEDIR}/System/Library/Documentation -type d -empty -delete

.include <bsd.port.mk>
