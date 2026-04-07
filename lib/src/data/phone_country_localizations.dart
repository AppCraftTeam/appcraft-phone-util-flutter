import 'package:flutter/material.dart';

import '../assets/localizations/ar.dart';
import '../assets/localizations/bg.dart';
import '../assets/localizations/ca.dart';
import '../assets/localizations/cn.dart';
import '../assets/localizations/cs.dart';
import '../assets/localizations/da.dart';
import '../assets/localizations/de.dart';
import '../assets/localizations/en.dart';
import '../assets/localizations/es.dart';
import '../assets/localizations/et.dart';
import '../assets/localizations/fa.dart';
import '../assets/localizations/fr.dart';
import '../assets/localizations/gr.dart';
import '../assets/localizations/he.dart';
import '../assets/localizations/hr.dart';
import '../assets/localizations/ht.dart';
import '../assets/localizations/id.dart';
import '../assets/localizations/it.dart';
import '../assets/localizations/ja.dart';
import '../assets/localizations/ko.dart';
import '../assets/localizations/ku.dart';
import '../assets/localizations/lt.dart';
import '../assets/localizations/lv.dart';
import '../assets/localizations/nb.dart';
import '../assets/localizations/nl.dart';
import '../assets/localizations/nn.dart';
import '../assets/localizations/np.dart';
import '../assets/localizations/pl.dart';
import '../assets/localizations/pt.dart';
import '../assets/localizations/ro.dart';
import '../assets/localizations/ru.dart';
import '../assets/localizations/sk.dart';
import '../assets/localizations/tr.dart';
import '../assets/localizations/tw.dart';
import '../assets/localizations/uk.dart';

class PhoneCountryLocalizations {
  const PhoneCountryLocalizations(this.locale);

  final Locale locale;

  String? countryName({
    required String isoCode
  }) {
    switch (locale.languageCode) {
      case 'zh':
        switch (locale.scriptCode) {
          case 'Hant':
            return tw[isoCode];
          case 'Hans':
          default:
            return cn[isoCode];
        }
      case 'el':
        return gr[isoCode];
      case 'es':
        return es[isoCode];
      case 'et':
        return et[isoCode];
      case 'he':
        return he[isoCode];
      case 'pt':
        return pt[isoCode];
      case 'nb':
        return nb[isoCode];
      case 'nn':
        return nn[isoCode];
      case 'uk':
        return uk[isoCode];
      case 'pl':
        return pl[isoCode];
      case 'tr':
        return tr[isoCode];
      case 'ro':
        return ro[isoCode];
      case 'ru':
        return ru[isoCode];
      case 'sk':
        return sk[isoCode];
      case 'hi':
      case 'ne':
        return np[isoCode];
      case 'ar':
        return ar[isoCode];
      case 'bg':
        return bg[isoCode];
      case 'ku':
        return ku[isoCode];
      case 'hr':
        return hr[isoCode];
      case 'ht':
        return ht[isoCode];
      case 'fr':
        return fr[isoCode];
      case 'de':
        return de[isoCode];
      case 'lv':
        return lv[isoCode];
      case 'lt':
        return lt[isoCode];
      case 'nl':
        return nl[isoCode];
      case 'it':
        return it[isoCode];
      case 'ko':
        return ko[isoCode];
      case 'ja':
        return ja[isoCode];
      case 'id':
        return id[isoCode];
      case 'cs':
        return cs[isoCode];
      case 'da':
        return da[isoCode];
      case 'ca':
        return ca[isoCode];
      case 'fa':
        return fa[isoCode];
      case 'en':
      default:
        return en[isoCode];
    }
  }
}
