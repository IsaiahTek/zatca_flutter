import 'package:xml/xml.dart';
import 'package:zatca_flutter/service/util.dart';

/// Represents delivery details in a transaction, including actual and latest delivery dates.
///
/// The [Delivery] class holds information about the actual delivery date and the latest possible
/// delivery date for a transaction. These dates are formatted according to ZATCA compliance standards.
/// The class includes:
/// - [actualDate]: The actual delivery date of the goods or services.
/// - [latestDate]: The latest date by which the delivery should occur.
class Delivery {
  /// The actual date when the delivery took place.
  DateTime actualDate;

  /// The latest date by which the delivery should occur.
  DateTime latestDate;

  /// Constructs a [Delivery] instance with the specified [actualDate] and [latestDate].
  ///
  /// [actualDate] represents the date when the delivery was completed.
  /// [latestDate] represents the latest permissible date for the delivery.
  Delivery({required this.actualDate, required this.latestDate});

  /// Returns the actual delivery date formatted in a ZATCA-compliant date string.
  ///
  /// The method calls a utility function to ensure the date complies with ZATCA standards.
  String get _aDate => getZatcaCompliantDate(actualDate);

  /// Returns the latest delivery date formatted in a ZATCA-compliant date string.
  ///
  /// The method calls a utility function to ensure the date complies with ZATCA standards.
  String get _lDate => getZatcaCompliantDate(latestDate);

  /// Converts the [Delivery] instance into an XML representation.
  ///
  /// The method generates XML elements for the actual and latest delivery dates.
  /// Example XML output:
  /// ```xml
  /// <cac:Delivery>
  ///   <cbc:ActualDeliveryDate>2025-04-23</cbc:ActualDeliveryDate>
  ///   <cbc:LatestDeliveryDate>2025-04-25</cbc:LatestDeliveryDate>
  /// </cac:Delivery>
  /// ```
  void toXml(XmlBuilder builder) {
    builder.element('cac:Delivery', nest: () {
      builder.element('cbc:ActualDeliveryDate', nest: _aDate);
      builder.element('cbc:LatestDeliveryDate', nest: _lDate);
    });
  }
}
