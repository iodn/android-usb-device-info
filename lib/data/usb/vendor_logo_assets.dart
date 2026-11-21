/// Bundled SVG filenames by USB vendor ID.
///
/// See tools/vendor_logo_sources.tsv for the source of each file.
const vendorLogoAssets = <int, String>{
  0x001f: 'walmart', // Walmart
  0x0200: 'tp-link', // TP-Link
  0x03e7: 'intel', // Intel
  0x03f0: 'hp', // HP, Inc
  0x03f5: 'siemens', // Siemens Electromechanical
  0x03f8: 'epson', // Epson Imaging Technology Center
  0x0406: 'fujitsu', // Fujitsu-ICL Computers
  0x0407: 'fujitsu', // Fujitsu Personal Systems, Inc.
  0x0409: 'nec', // NEC Corp.
  0x040a: 'kodak', // Kodak Co.
  0x0419: 'samsung', // Samsung Info. Systems America, Inc.
  0x041e: 'creative-technology', // Creative Technology, Ltd
  0x0421: 'nokia', // Nokia Mobile Phones
  0x0425: 'motorola', // Motorola Semiconductors HK, Ltd
  0x0427: 'motorola', // Motorola Electronics Taiwan, Ltd
  0x042a: 'ericsson', // Ericsson Austrian, AG
  0x042b: 'intel', // Intel Corp.
  0x042e: 'acer', // Acer, Inc.
  0x0430: 'fujitsu', // Fujitsu Component Limited
  0x0434: 'samsung', // Samsung Info. Systems America, Inc.
  0x0438: 'amd', // Advanced Micro Devices, Inc.
  0x043d: 'lexmark', // Lexmark International, Inc.
  0x0442: 'ericsson', // Ericsson, Inc.
  0x044d: 'siemens', // Siemens Nixdorf AG
  0x0450: 'dfi', // DFI, Inc.
  0x0451: 'texas-instruments', // Texas Instruments, Inc.
  0x0452: 'mitsubishi-electric', // Mitsubishi Electronics America, Inc.
  0x0459: 'adobe', // Adobe Systems, Inc.
  0x045b: 'hitachi', // Hitachi, Ltd
  0x045e: 'microsoft', // Microsoft Corp.
  0x046a: 'cherry', // CHERRY
  0x046c: 'toshiba', // Toshiba Corp., Digital Media Equipment
  0x046d: 'logitech', // Logitech, Inc.
  0x0477: 'seagate', // Seagate Technology, Inc.
  0x047c: 'dell', // Dell Computer Corp.
  0x047d: 'kensington', // Kensington
  0x0480: 'toshiba', // Toshiba America Inc
  0x0482: 'kyocera', // Kyocera Corp.
  0x0483: 'stmicroelectronics', // STMicroelectronics
  0x0485: 'nokia', // Nokia Monitors
  0x0486: 'asus', // ASUS Computers, Inc.
  0x0489: 'foxconn', // Foxconn / Hon Hai
  0x0492: 'samsung', // Samsung SemiConductor, Inc.
  0x0496: 'micron', // Micron Electronics
  0x0499: 'yamaha-corporation', // Yamaha Corp.
  0x049c: 'acer', // Acer Advanced Labs, Inc.
  0x04a4: 'hitachi', // Hitachi, Ltd
  0x04a5: 'benq', // Acer Peripherals Inc. (now BenQ Corp.)
  0x04a6: 'nokia', // Nokia Display Products
  0x04a9: 'canon', // Canon, Inc.
  0x04b0: 'nikon', // Nikon Corp.
  0x04b3: 'ibm', // IBM Corp.
  0x04b7: 'compal', // Compal Electronics, Inc.
  0x04b8: 'epson', // Seiko Epson Corp.
  0x04bd: 'toshiba', // Toshiba Electronics Taiwan Corp.
  0x04c4: 'lockheed-martin', // Lockheed Martin Energy Research
  0x04c5: 'fujitsu', // Fujitsu, Ltd
  0x04c6: 'toshiba', // Toshiba America Electronic Components
  0x04cb: 'fujifilm', // Fuji Photo Film Co., Ltd
  0x04da: 'panasonic', // Panasonic (Matsushita)
  0x04dd: 'sharp', // Sharp Corp.
  0x04e8: 'samsung', // Samsung Electronics Co., Ltd
  0x04f5: 'fujitsu', // Fujitsu-ICL Systems, Inc.
  0x04f9: 'brother', // Brother Industries, Ltd
  0x0502: 'acer', // Acer, Inc.
  0x0503: 'hitachi', // Hitachi America, Ltd
  0x050d: 'belkin', // Belkin Components
  0x0531: 'wacom', // Wacom Technology Corp.
  0x0534: 'motorola', // Motorola, Inc.
  0x0543: 'viewsonic', // ViewSonic Corp.
  0x054a: 'fujitsu', // Fujitsu Microelectronics, Inc.
  0x054c: 'sony', // Sony Corp.
  0x0552: 'philips', // Philips Monitors
  0x0553:
      'stmicroelectronics', // STMicroelectronics Imaging Division (VLSI Vision)
  0x055d: 'samsung', // Samsung Electro-Mechanics Co.
  0x0564: 'kodak', // Kodak Digital Product Center, Japan Ltd. (formerly Chinon Industries Inc.)
  0x056a: 'wacom', // Wacom Co., Ltd
  0x056e: 'elecom', // Elecom Co., Ltd
  0x0570: 'epson', // Epson America
  0x0575: 'philips', // Philips Creative Display Solutions
  0x057a: 'samsung', // Samsung Electronics America
  0x057c: 'avm', // AVM GmbH
  0x057e: 'nintendo', // Nintendo Co., Ltd
  0x0582: 'roland', // Roland Corp.
  0x059f: 'lacie', // LaCie, Ltd
  0x05a2: 'fujifilm', // Fuji Film Microdevices Co., Ltd
  0x05a6: 'cisco', // Cisco Systems, Inc.
  0x05a7: 'bose', // Bose Corp.
  0x05ac: 'apple', // Apple, Inc.
  0x05b1: 'first-international-computer', // First International Computer, Inc.
  0x05b9: 'philips', // Philips Research Laboratories
  0x05c6: 'qualcomm', // Qualcomm, Inc.
  0x05ca: 'ricoh', // Ricoh Co., Ltd
  0x05dc: 'lexar', // Lexar Media, Inc.
  0x05fa: 'siemens', // Siemens Telecommunications Systems, Ltd
  0x0634: 'micron', // Micron Technology, Inc.
  0x066b: 'linksys', // Linksys, Inc.
  0x066e: 'acer', // Acer Semiconductor America, Inc.
  0x0673: 'hcl', // HCL
  0x0675: 'draytek', // DrayTek Corp.
  0x0681: 'siemens', // Siemens Information and Communication Products
  0x0686: 'minolta', // Minolta Co., Ltd
  0x0694: 'lego', // Lego Group
  0x06ac: 'fujitsu', // Fujitsu Laboratories of America, Inc.
  0x06d3: 'mitsubishi-electric', // Mitsubishi Electric Corp.
  0x06d4: 'cisco', // Cisco Systems
  0x06d5: 'toshiba', // Toshiba
  0x06fc: 'motorola', // Motorola Semiconductor Products Sector
  0x073e: 'nec', // NEC, Inc.
  0x077b: 'linksys', // Linksys
  0x0781: 'sandisk', // SanDisk Corp.
  0x07b2: 'motorola', // Motorola BCS, Inc.
  0x07b4: 'olympus', // Olympus Optical Co., Ltd
  0x07d1: 'd-link', // D-Link System
  0x07fa: 'draytek', // DrayTek Corp.
  0x0813: 'mattel', // Mattel, Inc.
  0x0839: 'samsung', // Samsung Techwin Co., Ltd
  0x0846: 'netgear', // NetGear, Inc.
  0x0864: 'netgear', // NetGear, Inc.
  0x0871: 'sandisk', // SanDisk, Inc.
  0x087e: 'fujitsu', // Fujitsu Computer Products of America
  0x08a6: 'toshiba', // Toshiba TEC
  0x08bb: 'texas-instruments', // Texas Instruments
  0x08d4: 'fujitsu', // Fujitsu Siemens Computers
  0x08ea: 'ericsson', // Ericsson, Inc., Blue Ridge Labs
  0x08ed: 'mediatek', // MediaTek Inc.
  0x08f9: 'wipro', // Wipro Technologies
  0x0908: 'siemens', // Siemens AG
  0x0909: 'audio-technica', // Audio-Technica Corp.
  0x090f: 'fujitsu', // Fujitsu Devices, Inc.
  0x0911: 'philips', // Philips Speech Processing
  0x091e: 'garmin', // Garmin International
  0x092a: 'toshiba', // Toshiba Information & Industrial Sys. And Services
  0x0930: 'toshiba', // Toshiba Corp.
  0x0943: 'hcl', // HCL Technologies India Private, Ltd
  0x0951: 'kingston-technology', // Kingston Technology
  0x0955: 'nvidia', // NVIDIA Corp.
  0x099e: 'trimble', // Trimble Navigation, Ltd
  0x0a3c: 'ntt-docomo', // NTT DoCoMo, Inc.
  0x0a4b: 'fujitsu', // Fujitsu Media Devices, Ltd
  0x0a4e: 'steinberg', // Steinberg Soft-und Hardware GmbH
  0x0a51: 'sony', // Sony Electronics, Inc.
  0x0a5c: 'broadcom', // Broadcom Corp.
  0x0a5f: 'zebra-technologies', // Zebra Technologies
  0x0aae: 'nec', // NEC infrontia Corp. (Nitsuko)
  0x0b05: 'asus', // ASUSTek Computer, Inc.
  0x0b0f: 'avid', // AVID Technology
  0x0b37: 'hitachi', // Hitachi ULSI Systems Co., Ltd
  0x0b61: 'nec', // NEC Viewtechnology, Ltd
  0x0bb4: 'htc', // HTC (High Tech Computer Corp.)
  0x0bb8: 'hitachi', // Hitachi Semiconductor and Devices Sales Co., Ltd
  0x0bc2: 'seagate', // Seagate RSS LLC
  0x0bdb: 'ericsson', // Ericsson Business Mobile Networks BV
  0x0bdd: 'orange', // Orange PCS
  0x0bf8: 'fujitsu', // Fujitsu Siemens Computers
  0x0c06: 'hasbro', // Hasbro Games, Inc.
  0x0c44: 'motorola', // Motorola iDEN
  0x0c88: 'kyocera', // Kyocera Wireless Corp.
  0x0ca3: 'sega', // Sega Corp.
  0x0cad: 'motorola', // Motorola CGISS
  0x0cd9: 'hitachi', // Hitachi Shin Din Cable, Ltd
  0x0cf3: 'qualcomm', // Qualcomm Atheros Communications
  0x0d28: 'nxp', // NXP
  0x0d87: 'dolby', // Dolby Laboratories Inc.
  0x0da4: 'polar', // Polar Electro Oy
  0x0db0: 'msi', // Micro Star International
  0x0e0f: 'vmware', // VMware, Inc.
  0x0e56: 'kingston-technology', // Kingston Technology Company, Inc.
  0x0e8d: 'mediatek', // MediaTek Inc.
  0x0ef0: 'hitachi', // Hitachi Cable, Ltd
  0x0f73: 'dfi', // DFI
  0x0f7e: 'fluke', // Fluke Corp.
  0x0fb8: 'wistron', // Wistron Corp.
  0x0fd9: 'elgato', // Elgato Systems GmbH
  0x1004: 'lg', // LG Electronics, Inc.
  0x1038: 'steelseries', // SteelSeries ApS
  0x1050: 'yubico', // Yubico.com
  0x1058: 'western-digital', // Western Digital Technologies, Inc.
  0x105b: 'foxconn', // Foxconn International, Inc.
  0x1063: 'motorola', // Motorola Electronics Taiwan, Ltd [hex]
  0x1083: 'canon', // Canon Electronics, Inc.
  0x10ac: 'honeywell', // Honeywell, Inc.
  0x1132: 'toshiba', // Toshiba Corp., Digital Media Equipment [hex]
  0x1184: 'kyocera', // Kyocera Elco Corp.
  0x1189: 'acer', // Acer Communications & Multimedia
  0x11ac: 'nike', // Nike
  0x11f5: 'siemens', // Siemens AG
  0x1241: 'belkin', // Belkin
  0x125f: 'adata', // A-DATA Technology Co., Ltd.
  0x1293: 'belkin', // Belkin Components [hex]
  0x12d1: 'huawei', // Huawei Technologies Co., Ltd.
  0x1307: 'transcend', // Transcend Information, Inc.
  0x1377: 'sennheiser', // Sennheiser electronic GmbH & Co. KG
  0x1385: 'netgear', // Netgear, Inc
  0x1390: 'tomtom', // TOMTOM B.V.
  0x13b1: 'linksys', // Linksys
  0x1457: 'first-international-computer', // First International Computer, Inc.
  0x14c0: 'rockwell-automation', // Rockwell Automation, Inc.
  0x1509: 'first-international-computer', // First International Computer, Inc.
  0x1532: 'razer', // Razer USA, Ltd
  0x15ad: 'vmware', // VMware Inc.
  0x1617: 'sony', // Sony Corp.
  0x1689: 'razer', // Razer USA, Ltd
  0x1696: 'hitachi', // Hitachi Video and Information System, Inc.
  0x1770: 'msi', // MSI
  0x17cc: 'native-instruments', // Native Instruments
  0x17ef: 'lenovo', // Lenovo
  0x1809: 'advantech', // Advantech
  0x187c: 'alienware', // Alienware Corporation
  0x18a5: 'verbatim', // Verbatim, Ltd
  0x18d1: 'google', // Google Inc.
  0x190d: 'motorola', // Motorola GSG
  0x1915: 'nordic-semiconductor', // Nordic Semiconductor ASA
  0x19b4: 'celestron', // Celestron
  0x19d2: 'zte', // ZTE WCDMA Technologies MSM
  0x1a2a: 'seagate', // Seagate Branded Solutions
  0x1a61: 'abbott', // Abbott Diabetes Care
  0x1a79: 'bayer', // Bayer Health Care LLC
  0x1b1c: 'corsair', // Corsair
  0x1bc4: 'ford', // Ford Motor Co.
  0x1c04: 'qnap', // QNAP System Inc.
  0x1c1b: 'volkswagen', // Volkswagen of America, Inc.
  0x1d27: 'asus', // ASUS
  0x1e71: 'nzxt', // NZXT
  0x1e8e: 'airbus', // Airbus Defence and Space
  0x1edb: 'blackmagic-design', // Blackmagic design
  0x1f9b: 'ubiquiti', // Ubiquiti Networks, Inc.
  0x1fab: 'samsung', // Samsung Opto-Electroncs Co., Ltd.
  0x1fc9: 'nxp', // NXP Semiconductors
  0x2001: 'd-link', // D-Link Corp.
  0x2018: 'deutsche-telekom', // Deutsche Telekom AG
  0x2047: 'texas-instruments', // Texas Instruments
  0x21a4: 'electronic-arts', // Electronic Arts Inc.
  0x22a7: 'fortinet', // Fortinet Technologies
  0x22b8: 'motorola', // Motorola PCS
  0x22d9: 'oppo', // OPPO Electronics Corp.
  0x2341: 'arduino', // Arduino SA
  0x2357: 'tp-link', // TP-Link
  0x239a: 'adafruit', // Adafruit
  0x2516: 'cooler-master', // Cooler Master Co., Ltd.
  0x2687: 'fitbit', // Fitbit Inc.
  0x2717: 'xiaomi', // Xiaomi Inc.
  0x27a8: 'square', // Square, Inc.
  0x2821: 'asus', // ASUSTek Computer Inc.
  0x2a45: 'meizu', // Meizu Corp.
  0x2a70: 'oneplus', // OnePlus Technology (Shenzhen) Co., Ltd.
  0x2ae5: 'fairphone', // Fairphone B.V.
  0x2b23: 'red-hat', // Red Hat, Inc.
  0x2c23: 'supermicro', // Supermicro Computer Incorporated
  0x2c97: 'ledger', // Ledger
  0x2ca3: 'dji', // DJI Technology Co., Ltd.
  0x2d1f: 'wacom', // Wacom Taiwan Information Co. Ltd.
  0x2fb2: 'fujitsu', // Fujitsu, Ltd
  0x2fe3: 'nordic-semiconductor', // NordicSemiconductor
  0x30ee: 'fujitsu', // Fujitsu Connected Technologies Limited
  0x316d: 'purism', // Purism, SPC
  0x3384: 'system76', // System76
  0x413c: 'dell', // Dell Computer Corp.
  0x4317: 'broadcom', // Broadcom Corp.
  0x6472: 'sony', // Sony Corp.
  0x8086: 'intel', // Intel Corp.
  0x8087: 'intel', // Intel Corp.
  0x8564: 'transcend', // Transcend Information, Inc.
};

/// Logos supplied in white or other light colors.
const vendorLogosForDarkBackground = {
  'apple',
  'cisco',
  'fluke',
  'htc',
  'kensington',
  'lexmark',
  'nikon',
  'philips',
  'polar',
  'razer',
  'sony',
};
