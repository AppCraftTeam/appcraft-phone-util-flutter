/// A Flutter utility library for phone number parsing, validation,
/// formatting and country detection.
///
/// Provides [ACPhoneUtil] for phone number operations,
/// [ACPhoneCountry] for country metadata, [ACPhoneCountries] for the
/// registry of supported countries, [ACPhoneData] for parsed results,
/// [ACPhoneMasked] for mask application, and
/// [ACPhoneCountryLocalizations] for localized country names.
library ac_phone_util;

export 'src/data/ac_phone_countries.dart';
export 'src/data/ac_phone_country_localizations.dart';
export 'src/domain/ac_phone_country.dart';
export 'src/domain/ac_phone_data.dart';
export 'src/domain/ac_phone_masked.dart';

export 'src/ac_phone_util.dart';

export 'src/presentation/ac_phone_presentation.dart';
