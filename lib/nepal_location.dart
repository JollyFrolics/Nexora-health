// // nepal_locations.dart
// // Nepal Administrative Divisions — Complete Official Data
// // 7 Provinces · 77 Districts · 753 Local Units
// //
// // Abbreviations used in unit names:
// //   म.न.पा.    = महानगरपालिका   (Metropolitan City)       — 6 units
// //   उप.म.न.पा. = उपमहानगरपालिका (Sub-Metropolitan City)  — 11 units
// //   न.पा.      = नगरपालिका       (Municipality)            — 276 units
// //   गा.पा.     = गाउँपालिका      (Rural Municipality)      — 460 units

// class NepalLocation {
//   static const Map<String, Map<String, List<String>>> data = {
//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 1 — कोशी प्रदेश  (14 districts)
//     // ══════════════════════════════════════════════════════════════
//     'कोशी प्रदेश': {
//       'ताप्लेजुङ': [
//         'फुङलिङ न.पा.',
//         'सिदिङ्वा गा.पा.',
//         'फक्ताङलुङ गा.पा.',
//         'मिक्वाखोला गा.पा.',
//         'मेरिङदेन गा.पा.',
//         'सिरीजंघा गा.पा.',
//         'आठराई त्रिवेणी गा.पा.',
//         'पाथीभरा याङवरक गा.पा.',
//       ],
//       'सङ्खुवासभा': [
//         'खाँदबारी न.पा.',
//         'धर्मदेवी न.पा.',
//         'पाँचखपन न.पा.',
//         'मादी न.पा.',
//         'चैनपुर न.पा.',
//         'सभापोखरी गा.पा.',
//         'सिलीचोङ गा.पा.',
//         'माकालु गा.पा.',
//         'बाँकु गा.पा.',
//         'क्रान्तिशिखर गा.पा.',
//       ],
//       'सोलुखुम्बु': [
//         'सोलुदूधकुण्ड न.पा.',
//         'दूधकोशी न.पा.',
//         'लिखु पिके गा.पा.',
//         'माहाकुलुङ गा.पा.',
//         'खुम्बु पासाङल्हमु गा.पा.',
//         'हुप्सेकोट गा.पा.',
//         'थुलुङ दूधकोशी गा.पा.',
//         'नेचासल्यान गा.पा.',
//       ],
//       'ओखलढुङ्गा': [
//         'सिद्धिचरण न.पा.',
//         'मोलुङ न.पा.',
//         'खिजिदेम्बा गा.पा.',
//         'चम्पादेवी गा.पा.',
//         'लिखु गा.पा.',
//         'मानेभञ्ज्याङ गा.पा.',
//         'सुनकोशी गा.पा.',
//         'टक्सार गा.पा.',
//       ],
//       'खोटाङ': [
//         'दिक्तेल रुपाकोट मझुवागढी न.पा.',
//         'हलेसी तुवाचुङ न.पा.',
//         'ऐसेलुखर्क न.पा.',
//         'दिप्रुङ चुइचुम्मा गा.पा.',
//         'जन्तेढुङ्गा गा.पा.',
//         'केपिलासगढी गा.पा.',
//         'खोटेहाङ गा.पा.',
//         'रावाबेसी गा.पा.',
//         'बराहपोखरी गा.पा.',
//       ],
//       'भोजपुर': [
//         'भोजपुर न.पा.',
//         'षडानन्द न.पा.',
//         'अरुण गा.पा.',
//         'पौवादुङमा गा.पा.',
//         'रामप्रसाद राई गा.पा.',
//         'हतुवागढी गा.पा.',
//         'टेम्केमैयुम गा.पा.',
//         'आमचोक गा.पा.',
//       ],
//       'धनकुटा': [
//         'धनकुटा न.पा.',
//         'पाख्रिबास न.पा.',
//         'महालक्ष्मी न.पा.',
//         'चौबिसे गा.पा.',
//         'सहिदभूमि गा.पा.',
//         'छथर जोरपाटी गा.पा.',
//         'ख्याली गा.पा.',
//       ],
//       'तेह्रथुम': [
//         'म्याङलुङ न.पा.',
//         'लालिगुराँस न.पा.',
//         'आठराई गा.पा.',
//         'छथर गा.पा.',
//         'फेदाप गा.पा.',
//         'मेन्छयायेम गा.पा.',
//         'साम्पाङ गा.पा.',
//       ],
//       'इलाम': [
//         'इलाम न.पा.',
//         'देउमाई न.पा.',
//         'फाकफोकथुम न.पा.',
//         'माई न.पा.',
//         'सूर्योदय न.पा.',
//         'चुलाचुली गा.पा.',
//         'माइजोगमाई गा.पा.',
//         'रोङ गा.पा.',
//         'सन्दकपुर गा.पा.',
//       ],
//       'पाँचथर': [
//         'फिदिम न.पा.',
//         'फालेलुङ गा.पा.',
//         'हिलिहाङ गा.पा.',
//         'कुम्मायक गा.पा.',
//         'मिक्लाजुङ गा.पा.',
//         'फाल्गुनन्द गा.पा.',
//         'याङवरक गा.पा.',
//       ],
//       'झापा': [
//         'भद्रपुर न.पा.',
//         'बुद्धशान्ति न.पा.',
//         'दमक न.पा.',
//         'गौरादह न.पा.',
//         'हल्दिबारी न.पा.',
//         'कँकडभिट्टा न.पा.',
//         'मेची न.पा.',
//         'शिवसताक्षी न.पा.',
//         'अर्जुनधारा न.पा.',
//         'बाराहक्षेत्र न.पा.',
//         'कमल न.पा.',
//         'झापा गा.पा.',
//         'गौरीगञ्ज गा.पा.',
//       ],
//       'मोरङ': [
//         'बिराटनगर म.न.पा.', // Metropolitan ★
//         'इटहरी उप.म.न.पा.', // Sub-Metro ★
//         'बेलबारी न.पा.', 'बुढीगङ्गा न.पा.', 'कटहरी न.पा.',
//         'केरावारी न.पा.', 'लेटाङ न.पा.', 'पथरी शनिश्चरे न.पा.',
//         'रङेली न.पा.', 'रतुवामाई न.पा.', 'सुन्दरहरैचा न.पा.',
//         'उर्लाबारी न.पा.', 'ग्रामथान गा.पा.', 'जहदा गा.पा.',
//         'विष्णुपुर गा.पा.', 'टोखर माझगाउँ गा.पा.',
//       ],
//       'सुनसरी': [
//         'धरान उप.म.न.पा.', // Sub-Metro ★
//         'इटाहरी उप.म.न.पा.', // Sub-Metro ★
//         'इनरुवा न.पा.', 'बराहक्षेत्र न.पा.', 'दुहबी न.पा.',
//         'भोक्राहा नरसिंह न.पा.', 'रामधुनी न.पा.', 'कोशी गा.पा.',
//         'हरिनगर गा.पा.', 'देवानगञ्ज गा.पा.', 'गढी गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 2 — मधेश प्रदेश  (8 districts)
//     // ══════════════════════════════════════════════════════════════
//     'मधेश प्रदेश': {
//       'सप्तरी': [
//         'राजविराज न.पा.',
//         'हनुमाननगर कंकालिनी न.पा.',
//         'बोदेबरसाइन न.पा.',
//         'छिन्नमस्ता न.पा.',
//         'डाकनेश्वरी न.पा.',
//         'कञ्चनरुप न.पा.',
//         'खडक न.पा.',
//         'शम्भुनाथ न.पा.',
//         'सुरुङ्गा न.पा.',
//         'अग्निसाइर कृष्णासवरन न.पा.',
//         'तिलाठी कोइलाडी न.पा.',
//         'बलान-बिहुल गा.पा.',
//         'महादेवा गा.पा.',
//         'रुपनी गा.पा.',
//       ],
//       'सिरहा': [
//         'लहान न.पा.',
//         'धनगढीमाई न.पा.',
//         'गोलबजार न.पा.',
//         'कर्जन्हा न.पा.',
//         'मिर्चैया न.पा.',
//         'नवराजपुर न.पा.',
//         'सखुवानान्कारकट्टी न.पा.',
//         'सिरहा न.पा.',
//         'सुखीपुर न.पा.',
//         'अर्नमा गा.पा.',
//         'औरहा गा.पा.',
//         'विष्णुपुर गा.पा.',
//         'कल्याणपुर गा.पा.',
//         'नरहा गा.पा.',
//       ],
//       'धनुषा': [
//         'जनकपुरधाम उप.म.न.पा.', // Sub-Metro ★
//         'क्षिरेश्वरनाथ न.पा.', 'गणेशमान चारनाथ न.पा.',
//         'धनुषाधाम न.पा.', 'जनकनन्दिनी न.पा.', 'मिथिला न.पा.',
//         'मिथिला बिहारी न.पा.', 'नगराइन न.पा.', 'शहीदनगर न.पा.',
//         'विदेह न.पा.', 'हंसपुर न.पा.', 'अरुणखोला गा.पा.',
//         'बटेश्वर गा.पा.', 'दिव्यसुन्दरी गा.पा.',
//         'लक्ष्मीनिया गा.पा.', 'मुखियापट्टी मुसहरमिया गा.पा.',
//       ],
//       'महोत्तरी': [
//         'जलेश्वर न.पा.',
//         'बर्दिबास न.पा.',
//         'भंगाहा न.पा.',
//         'गौशाला न.पा.',
//         'लोहरपट्टी न.पा.',
//         'मनरा शिसवा न.पा.',
//         'मटिहानी न.पा.',
//         'रामगोपालपुर न.पा.',
//         'सोनमा न.पा.',
//         'औरही गा.पा.',
//         'एकडारा गा.पा.',
//         'महोत्तरी गा.पा.',
//         'पिपरादी गा.पा.',
//         'साम्सी गा.पा.',
//         'खेयर खेयर गा.पा.',
//       ],
//       'सर्लाही': [
//         'मलंगवा न.पा.',
//         'हरिपुर न.पा.',
//         'हरिवन न.पा.',
//         'ईश्वरपुर न.पा.',
//         'लालबन्दी न.पा.',
//         'बरहथवा न.पा.',
//         'बागमती न.पा.',
//         'गोडैटा न.पा.',
//         'बलरा न.पा.',
//         'कविलासी न.पा.',
//         'परसा न.पा.',
//         'चक्रघट्टा गा.पा.',
//         'ब्रह्मपुरी गा.पा.',
//         'हरिनगर गा.पा.',
//         'कौडेना गा.पा.',
//         'राम नगर गा.पा.',
//       ],
//       'रौतहट': [
//         'गौर न.पा.',
//         'चन्द्रपुर न.पा.',
//         'राजपुर न.पा.',
//         'गरुडा न.पा.',
//         'गढीमाई न.पा.',
//         'देवाही गोनाही न.पा.',
//         'दुर्गाभगवती न.पा.',
//         'ईशनाथ न.पा.',
//         'कटहरिया न.पा.',
//         'माधव नारायण न.पा.',
//         'मौलापुर न.पा.',
//         'परोहा न.पा.',
//         'यमुनामाई न.पा.',
//         'बृन्दावन गा.पा.',
//         'राजदेवी न.पा.',
//       ],
//       'बारा': [
//         'कलैया उप.म.न.पा.', // Sub-Metro ★
//         'जितपुर सिमरा उप.म.न.पा.', // Sub-Metro ★
//         'कोल्हवी न.पा.', 'निजगढ न.पा.', 'महागढीमाई न.पा.',
//         'पचरौता न.पा.', 'परवानीपुर न.पा.', 'विश्रामपुर न.पा.',
//         'फेटा न.पा.', 'सिम्रौनगढ न.पा.', 'करैयामाई गा.पा.',
//         'देवताल गा.पा.', 'प्रसौनी गा.पा.', 'आदर्शकोटवाल गा.पा.',
//       ],
//       'पर्सा': [
//         'वीरगञ्ज म.न.पा.', // Metropolitan ★
//         'पोखरिया न.पा.', 'बहुदरमाई न.पा.', 'बिन्दबासिनी न.पा.',
//         'छिपहरमाई न.पा.', 'ढोलबाहा गा.पा.', 'जगरनाथपुर गा.पा.',
//         'जिरा भवानी गा.पा.', 'कालिकामाई गा.पा.', 'लोथर गा.पा.',
//         'पकाहा मैनपुर गा.पा.', 'पटेर्वा सुगौली गा.पा.',
//         'सखुवा प्रसौनी गा.पा.', 'ठोरी गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 3 — बागमती प्रदेश  (13 districts)
//     // ══════════════════════════════════════════════════════════════
//     'बागमती प्रदेश': {
//       'काठमाडौं': [
//         'काठमाडौं म.न.पा.', // Metropolitan ★
//         'कागेश्वरी मनोहरा न.पा.', 'किर्तिपुर न.पा.',
//         'गोकर्णेश्वर न.पा.', 'चन्द्रागिरि न.पा.', 'टोखा न.पा.',
//         'तारकेश्वर न.पा.', 'दक्षिणकाली न.पा.', 'नागार्जुन न.पा.',
//         'बुढानिलकण्ठ न.पा.', 'शङ्खरापुर न.पा.',
//       ],
//       'ललितपुर': [
//         'ललितपुर म.न.पा.', // Metropolitan ★
//         'गोदावरी न.पा.', 'महालक्ष्मी न.पा.', 'बाग्मती न.पा.',
//         'बज्रबाराही न.पा.', 'कोन्ज्योसोम गा.पा.', 'महाङ्काल गा.पा.',
//       ],
//       'भक्तपुर': [
//         'भक्तपुर न.पा.',
//         'चाँगुनारायण न.पा.',
//         'मध्यपुर थिमि न.पा.',
//         'सूर्यविनायक न.पा.',
//       ],
//       'काभ्रेपलाञ्चोक': [
//         'धुलिखेल न.पा.',
//         'बनेपा न.पा.',
//         'पनौती न.पा.',
//         'पाँचखाल न.पा.',
//         'मण्डनदेउपुर न.पा.',
//         'नमोबुद्ध न.पा.',
//         'खानीखोला गा.पा.',
//         'चौंरीदेउराली गा.पा.',
//         'तेमाल गा.पा.',
//         'बेथानचोक गा.पा.',
//         'महाभारत गा.पा.',
//         'रोशी गा.पा.',
//       ],
//       'सिन्धुपाल्चोक': [
//         'चौतारा साँगाचोकगढी न.पा.',
//         'बाह्रबिसे न.पा.',
//         'मेलम्ची न.पा.',
//         'इन्द्रावती गा.पा.',
//         'त्रिपुरासुन्दरी गा.पा.',
//         'लिसङ्खु पाखर गा.पा.',
//         'हेलम्बु गा.पा.',
//         'भोटेकोशी गा.पा.',
//         'जुगल गा.पा.',
//         'पाँचपोखरी थाङपाल गा.पा.',
//         'सुनकोशी गा.पा.',
//       ],
//       'रसुवा': [
//         'कालिका गा.पा.',
//         'गोसाइकुण्ड गा.पा.',
//         'नौकुण्ड गा.पा.',
//         'आमाछोदिङमो गा.पा.',
//         'उत्तरगया गा.पा.',
//       ],
//       'नुवाकोट': [
//         'विदुर न.पा.',
//         'बेलकोटगढी न.पा.',
//         'ककनी गा.पा.',
//         'किस्पाङ गा.पा.',
//         'दुप्चेश्वर गा.पा.',
//         'पञ्चकन्या गा.पा.',
//         'शिवपुरी गा.पा.',
//         'सुर्यगढी गा.पा.',
//         'तादी गा.पा.',
//         'लिखु गा.पा.',
//         'तारकेश्वर गा.पा.',
//       ],
//       'धादिङ': [
//         'निलकण्ठ न.पा.',
//         'खनियाबास न.पा.',
//         'धुनिबेसी न.पा.',
//         'ज्वालामुखी गा.पा.',
//         'गजुरी गा.पा.',
//         'गल्छी गा.पा.',
//         'गङ्गाजमुना गा.पा.',
//         'नेत्रावती डबजोङ गा.पा.',
//         'रुबीभ्याली गा.पा.',
//         'सिद्धलेक गा.पा.',
//         'थाक्रे गा.पा.',
//         'त्रिपुरासुन्दरी गा.पा.',
//         'केरूङ गा.पा.',
//       ],
//       'रामेछाप': [
//         'मन्थली न.पा.',
//         'रामेछाप न.पा.',
//         'उमाकुण्ड गा.पा.',
//         'गोकुलगङ्गा गा.पा.',
//         'खाँडादेवी गा.पा.',
//         'लिखु तामाकोशी गा.पा.',
//         'सुनापती गा.पा.',
//         'दोरम्बा गा.पा.',
//       ],
//       'सिन्धुली': [
//         'कमलामाई न.पा.',
//         'दुधौली न.पा.',
//         'गोलन्जोर गा.पा.',
//         'घ्याङलेख गा.पा.',
//         'हरिहरपुरगढी गा.पा.',
//         'मरिण गा.पा.',
//         'सुनकोशी गा.पा.',
//         'तीनपाटन गा.पा.',
//       ],
//       'मकवानपुर': [
//         'हेटौंडा उप.म.न.पा.', // Sub-Metro ★
//         'थाहा न.पा.', 'भीमफेदी गा.पा.', 'बाकलेर गा.पा.',
//         'इन्द्रसरोवर गा.पा.', 'कैलाश गा.पा.',
//         'मकवानपुरगढी गा.पा.', 'मनहरी गा.पा.', 'राक्सिराङ गा.पा.',
//       ],
//       'चितवन': [
//         'भरतपुर म.न.पा.', // Metropolitan ★
//         'रत्ननगर न.पा.', 'खैरहनी न.पा.', 'कालिका न.पा.',
//         'माडी न.पा.', 'राप्ती न.पा.', 'इच्छाकामना गा.पा.',
//       ],
//       'दोलखा': [
//         'भीमेश्वर न.पा.',
//         'जिरी न.पा.',
//         'गौरीशंकर गा.पा.',
//         'बैतेश्वर गा.पा.',
//         'बिगु गा.पा.',
//         'कालिञ्चोक गा.पा.',
//         'मेलुङ गा.पा.',
//         'शैलुङ गा.पा.',
//         'तामाकोशी गा.पा.',
//         'विमानेश्वर गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 4 — गण्डकी प्रदेश  (11 districts)
//     // ══════════════════════════════════════════════════════════════
//     'गण्डकी प्रदेश': {
//       'कास्की': [
//         'पोखरा म.न.पा.', // Metropolitan ★
//         'अन्नपूर्ण गा.पा.', 'माछापुच्छ्रे गा.पा.',
//         'मादी गा.पा.', 'रूपा गा.पा.',
//       ],
//       'तनहुँ': [
//         'भानु न.पा.',
//         'व्यास न.पा.',
//         'भिमाद न.पा.',
//         'शुक्लागण्डकी न.पा.',
//         'आँबुखैरेनी गा.पा.',
//         'बन्दीपुर गा.पा.',
//         'देवघाट गा.पा.',
//         'घिरिङ गा.पा.',
//         'म्याग्दे गा.पा.',
//         'रिसिङ गा.पा.',
//         'तनहुँ गा.पा.',
//       ],
//       'गोर्खा': [
//         'गोर्खा न.पा.',
//         'आरुघाट गा.पा.',
//         'अजिरकोट गा.पा.',
//         'बारपाक सुलीकोट गा.पा.',
//         'भिमसेनथापा गा.पा.',
//         'चुम नुब्री गा.पा.',
//         'धार्चे गा.पा.',
//         'गण्डकी गा.पा.',
//         'ताकुकोट गा.पा.',
//         'तसर्पु गा.पा.',
//         'शहीद लखन गा.पा.',
//       ],
//       'लमजुङ': [
//         'बेसीशहर न.पा.',
//         'मध्यनेपाल न.पा.',
//         'सुन्दरबजार न.पा.',
//         'क्व्होलासोथर गा.पा.',
//         'दोर्दी गा.पा.',
//         'दूधपोखरी गा.पा.',
//         'मर्स्याङदी गा.पा.',
//         'नवलपुर गा.पा.',
//         'रारा घाट गा.पा.',
//       ],
//       'स्याङ्जा': [
//         'पुतलीबजार न.पा.',
//         'भीरकोट न.पा.',
//         'गल्याङ न.पा.',
//         'वालिङ न.पा.',
//         'बिरुवा न.पा.',
//         'चापाकोट न.पा.',
//         'आँधीखोला गा.पा.',
//         'अर्जुनचौपारी गा.पा.',
//         'हर्मी गा.पा.',
//         'कालीगण्डकी गा.पा.',
//         'फेदीखोला गा.पा.',
//       ],
//       'पर्वत': [
//         'कुश्मा न.पा.',
//         'फलेवास न.पा.',
//         'जलजला गा.पा.',
//         'मोदी गा.पा.',
//         'पैयूँ गा.पा.',
//         'विहादी गा.पा.',
//         'महाशिला गा.पा.',
//       ],
//       'बाग्लुङ': [
//         'बाग्लुङ न.पा.',
//         'गल्कोट न.पा.',
//         'ढोरपाटन न.पा.',
//         'जैमिनी न.पा.',
//         'काठेखोला गा.पा.',
//         'निसीखोला गा.पा.',
//         'तमानखोला गा.पा.',
//         'वरेङ गा.पा.',
//         'बडीगाड गा.पा.',
//       ],
//       'म्याग्दी': [
//         'बेनी न.पा.',
//         'अन्नपूर्ण गा.पा.',
//         'धवलागिरि गा.पा.',
//         'मंगला गा.पा.',
//         'मालिका गा.पा.',
//         'रघुगंगा गा.पा.',
//       ],
//       'मुस्ताङ': [
//         'मुस्ताङ न.पा.',
//         'लो-घेकर दामोदरकुण्ड गा.पा.',
//         'लोमन्थाङ गा.पा.',
//         'महाकाली गा.पा.',
//         'घरपझोङ गा.पा.',
//       ],
//       'मनाङ': [
//         'नासोँ गा.पा.',
//         'नार्पा भूमि गा.पा.',
//         'चामे गा.पा.',
//         'मनाङ न्स्याङ गा.पा.',
//       ],
//       'नवलपुर': [
//         'कावासोती न.पा.',
//         'गैंडाकोट न.पा.',
//         'मध्यबिन्दु न.पा.',
//         'बौद्धिकाली न.पा.',
//         'देवचुली न.पा.',
//         'हुप्सेकोट न.पा.',
//         'बुलिङटार गा.पा.',
//         'त्रिवेणी गा.पा.',
//         'विनयी त्रिवेणी गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 5 — लुम्बिनी प्रदेश  (12 districts)
//     // ══════════════════════════════════════════════════════════════
//     'लुम्बिनी प्रदेश': {
//       'रूपन्देही': [
//         'बुटवल उप.म.न.पा.', // Sub-Metro ★
//         'सिद्धार्थनगर न.पा.', 'देवदह न.पा.',
//         'लुम्बिनी सांस्कृतिक न.पा.', 'तिलोत्तमा न.पा.',
//         'सैनामैना न.पा.', 'मर्चवारी गा.पा.', 'मायादेवी गा.पा.',
//         'ओमसतिया गा.पा.', 'रोहिणी गा.पा.',
//         'सम्मरीमाई गा.पा.', 'शुद्धोधन गा.पा.',
//       ],
//       'कपिलवस्तु': [
//         'कपिलवस्तु न.पा.',
//         'बाणगङ्गा न.पा.',
//         'बुद्धभूमि न.पा.',
//         'कृष्णनगर न.पा.',
//         'महाराजगञ्ज न.पा.',
//         'शिवराज न.पा.',
//         'विजयनगर गा.पा.',
//         'यसोधरा गा.पा.',
//       ],
//       'नवलपरासी (बर्दघाट सुस्ता पश्चिम)': [
//         'रामग्राम न.पा.',
//         'सुस्ता न.पा.',
//         'बर्दघाट न.पा.',
//         'पाल्हीनन्दन गा.पा.',
//         'प्रतापपुर गा.पा.',
//         'सरावल गा.पा.',
//       ],
//       'पाल्पा': [
//         'तानसेन न.पा.',
//         'बगनासकाली गा.पा.',
//         'माथागढी गा.पा.',
//         'निस्दी गा.पा.',
//         'पूर्वखोला गा.पा.',
//         'रैनादेवी छहरा गा.पा.',
//         'रिब्दीकोट गा.पा.',
//         'रम्भा गा.पा.',
//         'तिनाउ गा.पा.',
//       ],
//       'अर्घाखाँची': [
//         'सन्धिखर्क न.पा.',
//         'भूमिकास्थान न.पा.',
//         'शितगङ्गा न.पा.',
//         'छत्रदेव गा.पा.',
//         'मालारानी गा.पा.',
//         'पाणिनी गा.पा.',
//         'सीताराम गा.पा.',
//       ],
//       'गुल्मी': [
//         'रेसुङ्गा न.पा.',
//         'मुसिकोट न.पा.',
//         'इस्मा गा.पा.',
//         'कालिगण्डकी गा.पा.',
//         'मालिका गा.पा.',
//         'रुरु गा.पा.',
//         'चन्द्रकोट गा.पा.',
//         'ग्लेश्वर गा.पा.',
//         'छत्रकोट गा.पा.',
//         'धुर्कोट गा.पा.',
//         'सत्यवती गा.पा.',
//       ],
//       'प्युठान': [
//         'प्युठान न.पा.',
//         'स्वर्गद्वारी न.पा.',
//         'सरुमारानी गा.पा.',
//         'गौमुखी गा.पा.',
//         'माण्डवी गा.पा.',
//         'नौबहिनी गा.पा.',
//         'झिमरुक गा.पा.',
//         'आँधीपहाडा गा.पा.',
//         'मालारानी गा.पा.',
//       ],
//       'रोल्पा': [
//         'रोल्पा न.पा.',
//         'रुन्टीगढी गा.पा.',
//         'माडी गा.पा.',
//         'त्रिवेणी गा.पा.',
//         'सुनछहरी गा.पा.',
//         'लुङ्री गा.पा.',
//         'गमाडी गा.पा.',
//         'थवाङ गा.पा.',
//       ],
//       'रुकुम (पूर्व)': [
//         'पुथा उत्तरगङ्गा गा.पा.',
//         'सिस्ने गा.पा.',
//         'भूमे गा.पा.',
//       ],
//       'बाँके': [
//         'नेपालगञ्ज उप.म.न.पा.', // Sub-Metro ★
//         'कोहलपुर न.पा.', 'डुडुवा गा.पा.', 'खजुरा गा.पा.',
//         'नरैनापुर गा.पा.', 'राप्ती सोनारी गा.पा.',
//       ],
//       'बर्दिया': [
//         'गुलरिया न.पा.',
//         'ठाकुरबाबा न.पा.',
//         'बारबर्दिया न.पा.',
//         'बाँसगढी न.पा.',
//         'राजापुर न.पा.',
//         'मेदनी नगर न.पा.',
//         'बढैयाताल गा.पा.',
//         'गेरुवा गा.पा.',
//       ],
//       'दाङ': [
//         'घोराही उप.म.न.पा.', // Sub-Metro ★
//         'तुल्सीपुर उप.म.न.पा.', // Sub-Metro ★
//         'लमही न.पा.', 'राजपुर न.पा.', 'बंगलाचुली गा.पा.',
//         'बबई गा.पा.', 'दङ्गीशरण गा.पा.', 'गढवा गा.पा.',
//         'राप्ती गा.पा.', 'शान्तिनगर गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 6 — कर्णाली प्रदेश  (10 districts)
//     // ══════════════════════════════════════════════════════════════
//     'कर्णाली प्रदेश': {
//       'सुर्खेत': [
//         'वीरेन्द्रनगर न.पा.',
//         'गुर्भाकोट न.पा.',
//         'भेरीगंगा न.पा.',
//         'लेकबेसी न.पा.',
//         'पञ्चपुरी न.पा.',
//         'बराहताल गा.पा.',
//         'चिङ्गाड गा.पा.',
//         'सिम्ता गा.पा.',
//       ],
//       'दैलेख': [
//         'दुल्लु न.पा.',
//         'नारायण न.पा.',
//         'आठबिस न.पा.',
//         'चामुण्डा विन्द्रासैनी न.पा.',
//         'भैरवी गा.पा.',
//         'डुङ्गेश्वर गा.पा.',
//         'गुराँस गा.पा.',
//         'महाबु गा.पा.',
//         'ठाँटीकाँध गा.पा.',
//         'नौमुले गा.पा.',
//       ],
//       'जाजरकोट': [
//         'भेरी न.पा.',
//         'छेडागाड न.पा.',
//         'नलगाड न.पा.',
//         'बाँफिकोट गा.पा.',
//         'जुनीचाँदे गा.पा.',
//         'कुसे गा.पा.',
//         'शिवालय गा.पा.',
//       ],
//       'डोल्पा': [
//         'त्रिपुरासुन्दरी न.पा.',
//         'ठूली भेरी न.पा.',
//         'काईके गा.पा.',
//         'डोल्पो बुद्ध गा.पा.',
//         'मुड्केचुला गा.पा.',
//         'शे फोक्सुन्डो गा.पा.',
//         'छार्का ताङसोङ गा.पा.',
//         'वागाडो गा.पा.',
//       ],
//       'मुगु': [
//         'चंखेली गा.पा.',
//         'खत्याड गा.पा.',
//         'मुगुम कार्मारोङ गा.पा.',
//         'सोरु गा.पा.',
//       ],
//       'हुम्ला': [
//         'सिमकोट गा.पा.',
//         'अदानचुली गा.पा.',
//         'खार्पुनाथ गा.पा.',
//         'नाम्खा गा.पा.',
//         'सर्केगाड गा.पा.',
//         'ताँजाकोट गा.पा.',
//       ],
//       'कालीकोट': [
//         'खाँडाचक्र न.पा.',
//         'रास्कोट न.पा.',
//         'पचालझरना गा.पा.',
//         'पलाता गा.पा.',
//         'सान्नी त्रिवेणी गा.पा.',
//         'शुभकालिका गा.पा.',
//         'तिला गा.पा.',
//         'महाबु गा.पा.',
//       ],
//       'रुकुम (पश्चिम)': [
//         'मुसिकोट न.पा.',
//         'आठबिसकोट न.पा.',
//         'चौरजहारी न.पा.',
//         'बाँफिकोट गा.पा.',
//         'त्रिवेणी गा.पा.',
//         'सान्नी भेरी गा.पा.',
//       ],
//       'सल्यान': [
//         'बागचौर न.पा.',
//         'शारदा न.पा.',
//         'बनगाड कुपिण्डे न.पा.',
//         'कपुरकोट न.पा.',
//         'छत्रेश्वरी गा.पा.',
//         'कुमाख गा.पा.',
//         'दार्मा गा.पा.',
//         'त्रिवेणी गा.पा.',
//       ],
//       'जुम्ला': [
//         'चन्दननाथ न.पा.',
//         'कनकासुन्दरी गा.पा.',
//         'गुठीचौर गा.पा.',
//         'हिमा गा.पा.',
//         'पातारासी गा.पा.',
//         'सिञ्जा गा.पा.',
//         'तिला गा.पा.',
//       ],
//     },

//     // ══════════════════════════════════════════════════════════════
//     // PROVINCE 7 — सुदूरपश्चिम प्रदेश  (9 districts)
//     // ══════════════════════════════════════════════════════════════
//     'सुदूरपश्चिम प्रदेश': {
//       'कैलाली': [
//         'धनगढी उप.म.न.पा.', // Sub-Metro ★
//         'टीकापुर न.पा.', 'लम्कीचुहा न.पा.', 'अत्तरिया न.पा.',
//         'भजनी न.पा.', 'बर्दगोरिया न.पा.', 'गोदावरी न.पा.',
//         'गौरीगंगा न.पा.', 'जानकी गा.पा.', 'कैलारी गा.पा.',
//         'खैरला गा.पा.', 'मोहन्याल गा.पा.', 'चुरे गा.पा.',
//       ],
//       'कञ्चनपुर': [
//         'भीमदत्त न.पा.',
//         'पुर्नवास न.पा.',
//         'बेदकोट न.पा.',
//         'बेलौरी न.पा.',
//         'कृष्णपुर न.पा.',
//         'लालझाडी न.पा.',
//         'महाकाली न.पा.',
//         'शुक्लाफाँटा न.पा.',
//       ],
//       'डोटी': [
//         'दिपायल सिलगढी न.पा.',
//         'आदर्श कोटमंगलसेन न.पा.',
//         'शिखर न.पा.',
//         'बोगटान फुड्सिल गा.पा.',
//         'जोरायल गा.पा.',
//         'के.आई.सिंह गा.पा.',
//         'पूर्वीचौकी गा.पा.',
//         'सायल गा.पा.',
//       ],
//       'बझाङ': [
//         'बुंगल न.पा.',
//         'जयपृथ्वी न.पा.',
//         'बित्थडचिर गा.पा.',
//         'छबिसपाथिभेरा गा.पा.',
//         'दुर्गाथली गा.पा.',
//         'खप्तड छान्ना गा.पा.',
//         'मष्टा गा.पा.',
//         'सईपाल गा.पा.',
//         'सूर्मा गा.पा.',
//         'तलकोट गा.पा.',
//       ],
//       'बाजुरा': [
//         'बडीमालिका न.पा.',
//         'बुढीगंगा न.पा.',
//         'गौमूल गा.पा.',
//         'हिमाली गा.पा.',
//         'जगन्नाथ गा.पा.',
//         'स्वामीकार्तिक खापर गा.पा.',
//         'त्रिवेणी गा.पा.',
//         'तुर्माखाँद गा.पा.',
//       ],
//       'अछाम': [
//         'मंगलसेन न.पा.',
//         'कमलबजार न.पा.',
//         'पञ्चदेवल विनायक न.पा.',
//         'साँफेबगर न.पा.',
//         'बान्नीगढी जयगढ गा.पा.',
//         'चौरपाटी गा.पा.',
//         'ढकारी गा.पा.',
//         'मेल्लेख गा.पा.',
//         'राम रोशन गा.पा.',
//         'तुर्माखाँद गा.पा.',
//       ],
//       'डडेलधुरा': [
//         'अमरगढी न.पा.',
//         'परशुराम न.पा.',
//         'आलिताल गा.पा.',
//         'अजयमेरु गा.पा.',
//         'भागेश्वर गा.पा.',
//         'गन्यापधुरा गा.पा.',
//         'नवदुर्गा गा.पा.',
//       ],
//       'बैतडी': [
//         'दशरथचन्द न.पा.',
//         'पाटन न.पा.',
//         'डीलासैनी न.पा.',
//         'मेलौली न.पा.',
//         'पुर्चौडी न.पा.',
//         'डोगडाकेदार गा.पा.',
//         'शिवनाथ गा.पा.',
//         'सिगास गा.पा.',
//         'सुर्नया गा.पा.',
//         'पञ्चेश्वर गा.पा.',
//       ],
//       'दार्चुला': [
//         'महाकाली न.पा.',
//         'शैल्यशिखर न.पा.',
//         'मार्मा गा.पा.',
//         'नौगाड गा.पा.',
//         'दुहुँ गा.पा.',
//         'व्याँस गा.पा.',
//         'खलंगा गा.पा.',
//         'लेकम गा.पा.',
//         'मालिकार्जुन गा.पा.',
//       ],
//     },
//   };

//   static List<String> get provinces => data.keys.toList();
//   static List<String> districtsOf(String province) =>
//       data[province]?.keys.toList() ?? [];
//   static List<String> municipalitiesOf(String province, String district) =>
//       data[province]?[district] ?? [];

//   static bool isMetropolitan(String n) =>
//       n.contains('म.न.पा.') && !n.contains('उप.म.न.पा.');
//   static bool isSubMetropolitan(String n) => n.contains('उप.म.न.पा.');
//   static bool isMunicipality(String n) =>
//       n.contains('न.पा.') && !n.contains('म.न.पा.');
//   static bool isRural(String n) => n.contains('गा.पा.');

//   static String typeLabel(String n) {
//     if (isMetropolitan(n)) return 'महानगरपालिका';
//     if (isSubMetropolitan(n)) return 'उपमहानगरपालिका';
//     if (isMunicipality(n)) return 'नगरपालिका';
//     if (isRural(n)) return 'गाउँपालिका';
//     return '';
//   }
// }





class NepalLocation {
  static const Map<String, Map<String, List<String>>> data = {
    // ==============================
    // PROVINCE 1 — Koshi Province
    // ==============================
    'Koshi Province': {
      'Taplejung': [
        'Phungling Municipality',
        'Sidingwa Rural Municipality',
        'Phaktanglung Rural Municipality',
        'Mikwakhola Rural Municipality',
        'Meringden Rural Municipality',
        'Sirijangha Rural Municipality',
        'Aathrai Tribeni Rural Municipality',
        'Pathibhara Yangwarak Rural Municipality',
      ],
      'Sankhuwasabha': [
        'Khandbari Municipality',
        'Dharmadevi Municipality',
        'Panchkhapan Municipality',
        'Madi Municipality',
        'Chainpur Municipality',
        'Sabhapokhari Rural Municipality',
        'Silichong Rural Municipality',
        'Makalu Rural Municipality',
        'Banku Rural Municipality',
        'Krantishikhar Rural Municipality',
      ],
      'Solukhumbu': [
        'Solududhkunda Municipality',
        'Dudh Koshi Municipality',
        'Likhu Pike Rural Municipality',
        'Mahakulung Rural Municipality',
        'Khumbu Pasanglhamu Rural Municipality',
        'Hupshekot Rural Municipality',
        'Thulung Dudhkoshi Rural Municipality',
        'Nechasalyan Rural Municipality',
      ],
      'Okhaldhunga': [
        'Siddhicharan Municipality',
        'Molung Municipality',
        'Khijidemba Rural Municipality',
        'Champadevi Rural Municipality',
        'Likhu Rural Municipality',
        'Manebhanjyang Rural Municipality',
        'Sunkoshi Rural Municipality',
        'Taksar Rural Municipality',
      ],
      'Khotang': [
        'Diktel Rupakot Majhuwagadhi Municipality',
        'Halesi Tuwachung Municipality',
        'Aiselukharka Municipality',
        'Diprung Chuichumma Rural Municipality',
        'Jantedhunga Rural Municipality',
        'Kepilasgadhi Rural Municipality',
        'Khotehang Rural Municipality',
        'Rawa Besi Rural Municipality',
        'Barahapokhari Rural Municipality',
      ],
      'Bhojpur': [
        'Bhojpur Municipality',
        'Shadananda Municipality',
        'Arun Rural Municipality',
        'Pauwadhunga Rural Municipality',
        'Ramprasad Rai Rural Municipality',
        'Hatuwagadhi Rural Municipality',
        'Temkemaiyum Rural Municipality',
        'Amchok Rural Municipality',
      ],
      'Dhankuta': [
        'Dhankuta Municipality',
        'Pakhribas Municipality',
        'Mahalaxmi Municipality',
        'Choubise Rural Municipality',
        'Sahidbhumi Rural Municipality',
        'Chhathar Jorpati Rural Municipality',
        'Khyali Rural Municipality',
      ],
      'Tehrathum': [
        'Myanglung Municipality',
        'Laligurans Municipality',
        'Aathrai Rural Municipality',
        'Chhathar Rural Municipality',
        'Phidap Rural Municipality',
        'Menchhayayem Rural Municipality',
        'Sampang Rural Municipality',
      ],
      'Illam': [
        'Illam Municipality',
        'Deumai Municipality',
        'Fakphokthum Municipality',
        'Mai Municipality',
        'Suryodaya Municipality',
        'Chulachuli Rural Municipality',
        'Maijogmai Rural Municipality',
        'Rong Rural Municipality',
        'Sandakpur Rural Municipality',
      ],
      'Jhapa': [
        'Bhadrapur Municipality',
        'Buddhashanti Municipality',
        'Damak Municipality',
        'Gauradaha Municipality',
        'Haldibari Municipality',
        'Kankai Municipality',
        'Mechinagar Municipality',
        'Shivasatakshi Municipality',
        'Arjundhara Municipality',
        'Barahakshetra Municipality',
        'Kamal Municipality',
        'Jhapa Rural Municipality',
        'Gaurigunj Rural Municipality',
      ],
      'Morang': [
        'Biratnagar Metropolitan City',
        'Itahari Sub-Metropolitan City',
        'Belbari Municipality',
        'Budhiganga Municipality',
        'Katahari Municipality',
        'Kerabari Municipality',
        'Letang Municipality',
        'Pathari Shanishchare Municipality',
        'Rangeli Municipality',
        'Ratuwamai Municipality',
        'Sundarharaicha Municipality',
        'Urlabari Municipality',
        'Gramthan Rural Municipality',
        'Jahada Rural Municipality',
        'Bishnupur Rural Municipality',
        'Tokhar Majhgaun Rural Municipality',
      ],
      'Sunsari': [
        'Dharan Sub-Metropolitan City',
        'Itahari Sub-Metropolitan City',
        'Inaruwa Municipality',
        'Barahakshetra Municipality',
        'Duhabi Municipality',
        'Bhokraha Narsingh Municipality',
        'Ramdhuni Municipality',
        'Koshi Rural Municipality',
        'Harinagar Rural Municipality',
        'Devangunj Rural Municipality',
        'Gadhi Rural Municipality',
      ],
    },

    // ==============================
    // PROVINCE 2 — Madhesh Province
    // ==============================
    'Madhesh Province': {
      'Saptari': [
        'Rajbiraj Municipality',
        'Hanumannagar Kankalini Municipality',
        'Bode Barsain Municipality',
        'Chhinnamasta Municipality',
        'Dakneshwari Municipality',
        'Kanchanrup Municipality',
        'Khadak Municipality',
        'Shambhunath Municipality',
        'Surunga Municipality',
        'Agnisair Krishna Savaran Municipality',
        'Tilathi Koiladi Municipality',
        'Balan Bihul Rural Municipality',
        'Mahadeva Rural Municipality',
        'Rupani Rural Municipality',
      ],
      'Siraha': [
        'Lahan Municipality',
        'Dhangadhimai Municipality',
        'Golbazar Municipality',
        'Kalyanpur Municipality',
        'Mirchaiya Municipality',
        'Nawarajpur Municipality',
        'Sakhuwa Nankarkatti Municipality',
        'Siraha Municipality',
        'Sukhipur Municipality',
        'Arnama Rural Municipality',
        'Aurahi Rural Municipality',
        'Bishnupur Rural Municipality',
        'Naraha Rural Municipality',
      ],
      'Dhanusha': [
        'Janakpur Sub-Metropolitan City',
        'Kshireswar Nath Municipality',
        'Ganeshman Charnath Municipality',
        'Dhanushadham Municipality',
        'Janaknandini Municipality',
        'Mithila Municipality',
        'Mithila Bihari Municipality',
        'Nagarain Municipality',
        'Shahidnagar Municipality',
        'Videha Municipality',
        'Hansapur Municipality',
      ],
    },

    // ==============================
    // PROVINCE 3 — Bagmati Province
    // ==============================
    'Bagmati Province': {
      'Kathmandu': [
        'Kathmandu Metropolitan City',
        'Kageshwari Manohara Municipality',
        'Kirtipur Municipality',
        'Gokarneshwar Municipality',
        'Chandragiri Municipality',
        'Tokha Municipality',
        'Tarkeshwar Municipality',
        'Dakshinkali Municipality',
        'Nagarjun Municipality',
        'Budhanilkantha Municipality',
        'Shankharapur Municipality',
      ],
      'Lalitpur': [
        'Lalitpur Metropolitan City',
        'Godawari Municipality',
        'Mahalaxmi Municipality',
        'Bagmati Rural Municipality',
        'Konjyosom Rural Municipality',
        'Mahankal Rural Municipality',
      ],
      'Bhaktapur': [
        'Bhaktapur Municipality',
        'Changu Narayan Municipality',
        'Madhyapur Thimi Municipality',
        'Suryabinayak Municipality',
      ],
      'Chitwan': [
        'Bharatpur Metropolitan City',
        'Ratnanagar Municipality',
        'Khairahani Municipality',
        'Kalika Municipality',
        'Madi Municipality',
        'Rapti Municipality',
        'Ichchhakamana Rural Municipality',
      ],
    },

    // ==============================
    // PROVINCE 4 — Gandaki Province
    // ==============================
    'Gandaki Province': {
      'Kaski': [
        'Pokhara Metropolitan City',
        'Annapurna Rural Municipality',
        'Machhapuchhre Rural Municipality',
        'Madi Rural Municipality',
        'Rupa Rural Municipality',
      ],
      'Tanahun': [
        'Bhanu Municipality',
        'Byas Municipality',
        'Shuklagandaki Municipality',
        'Bhimad Municipality',
        'Anbukhaireni Rural Municipality',
        'Bandipur Rural Municipality',
      ],
      'Lamjung': [
        'Besisahar Municipality',
        'Madhya Nepal Municipality',
        'Sundarbazar Municipality',
        'Rainas Municipality',
        'Marsyangdi Rural Municipality',
        'Dordi Rural Municipality',
      ],
      'Gorkha': [
        'Gorkha Municipality',
        'Palungtar Municipality',
        'Aarughat Rural Municipality',
        'Ajirkot Rural Municipality',
        'Bhimsenthapa Rural Municipality',
        'Chum Nubri Rural Municipality',
      ],
    },

    // ==============================
    // PROVINCE 5 — Lumbini Province
    // ==============================
    'Lumbini Province': {
      'Rupandehi': [
        'Butwal Sub-Metropolitan City',
        'Siddharthanagar Municipality',
        'Devdaha Municipality',
        'Tilottama Municipality',
        'Lumbini Sanskritik Municipality',
        'Sainamaina Municipality',
      ],
      'Kapilvastu': [
        'Kapilvastu Municipality',
        'Banganga Municipality',
        'Buddhabhumi Municipality',
        'Krishnanagar Municipality',
        'Shivaraj Municipality',
        'Maharajgunj Municipality',
      ],
      'Dang': [
        'Ghorahi Sub-Metropolitan City',
        'Tulsipur Sub-Metropolitan City',
        'Lamahi Municipality',
        'Rajpur Rural Municipality',
        'Banglachuli Rural Municipality',
      ],
    },

    // ==============================
    // PROVINCE 6 — Karnali Province
    // ==============================
    'Karnali Province': {
      'Surkhet': [
        'Birendranagar Municipality',
        'Gurbhakot Municipality',
        'Bheriganga Municipality',
        'Lekbeshi Municipality',
        'Panchpuri Municipality',
      ],
      'Dailekh': [
        'Narayan Municipality',
        'Dullu Municipality',
        'Aathabis Municipality',
        'Chamunda Bindrasaini Municipality',
        'Mahabu Rural Municipality',
      ],
      'Jajarkot': [
        'Bheri Municipality',
        'Chhedagad Municipality',
        'Nalgad Municipality',
        'Kuse Rural Municipality',
        'Junichande Rural Municipality',
      ],
    },

    // ==============================
    // PROVINCE 7 — Sudurpashchim Province
    // ==============================
    'Sudurpashchim Province': {
      'Kailali': [
        'Dhangadhi Sub-Metropolitan City',
        'Tikapur Municipality',
        'Lamkichuha Municipality',
        'Ghodaghodi Municipality',
        'Bhajani Municipality',
        'Godawari Municipality',
      ],
      'Kanchanpur': [
        'Bhimdatta Municipality',
        'Punarbas Municipality',
        'Bedkot Municipality',
        'Krishnapur Municipality',
        'Shuklaphanta Municipality',
      ],
      'Doti': [
        'Dipayal Silgadhi Municipality',
        'Shikhar Municipality',
        'Adarsha Kotmela Municipality',
        'Jorayal Rural Municipality',
      ],
    },
  };

  // ==============================
  // Helpers
  // ==============================
  static List<String> get provinces => data.keys.toList();

  static List<String> districtsOf(String province) =>
      data[province]?.keys.toList() ?? [];

  static List<String> municipalitiesOf(String province, String district) =>
      data[province]?[district] ?? [];

  static bool isMetropolitan(String n) => n.contains('Metropolitan City');

  static bool isSubMetropolitan(String n) =>
      n.contains('Sub-Metropolitan City');

  static bool isMunicipality(String n) =>
      n.contains('Municipality') && !n.contains('Metropolitan');

  static bool isRural(String n) => n.contains('Rural Municipality');

  static String typeLabel(String n) {
    if (isMetropolitan(n)) return 'Metropolitan City';
    if (isSubMetropolitan(n)) return 'Sub-Metropolitan City';
    if (isMunicipality(n)) return 'Municipality';
    if (isRural(n)) return 'Rural Municipality';
    return '';
  }
}
