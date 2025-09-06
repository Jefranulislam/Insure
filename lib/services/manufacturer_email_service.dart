class ManufacturerEmailService {
  static final Map<String, String> _manufacturerEmails = {
    // Electronics
    'Apple': 'support@apple.com',
    'Samsung': 'support@samsung.com',
    'Sony': 'support@sony.com',
    'LG': 'support@lg.com',
    'Dell': 'support@dell.com',
    'HP': 'support@hp.com',
    'Lenovo': 'support@lenovo.com',
    'ASUS': 'support@asus.com',
    'Acer': 'support@acer.com',
    'Microsoft': 'support@microsoft.com',
    'Google': 'support@google.com',
    'OnePlus': 'support@oneplus.com',
    'Huawei': 'support@huawei.com',
    'Xiaomi': 'support@xiaomi.com',
    'Oppo': 'support@oppo.com',
    'Vivo': 'support@vivo.com',
    'Realme': 'support@realme.com',
    'Nokia': 'support@nokia.com',
    'Motorola': 'support@motorola.com',
    'TCL': 'support@tcl.com',
    'Panasonic': 'support@panasonic.com',
    'Sharp': 'support@sharp.com',
    'Toshiba': 'support@toshiba.com',
    'Philips': 'support@philips.com',
    'JBL': 'support@jbl.com',
    'Bose': 'support@bose.com',
    'Beats': 'support@beats.com',
    'Sennheiser': 'support@sennheiser.com',
    'Canon': 'support@canon.com',
    'Nikon': 'support@nikon.com',
    'GoPro': 'support@gopro.com',
    'DJI': 'support@dji.com',

    // Home Appliances
    'Whirlpool': 'support@whirlpool.com',
    'GE': 'support@ge.com',
    'Bosch': 'support@bosch.com',
    'KitchenAid': 'support@kitchenaid.com',
    'Maytag': 'support@maytag.com',
    'Frigidaire': 'support@frigidaire.com',
    'Electrolux': 'support@electrolux.com',
    'Haier': 'support@haier.com',
    'Midea': 'support@midea.com',
    'Dyson': 'support@dyson.com',
    'Shark': 'support@shark.com',
    'Bissell': 'support@bissell.com',
    'Black+Decker': 'support@blackanddecker.com',
    'Cuisinart': 'support@cuisinart.com',
    'Ninja': 'support@ninja.com',
    'Instant Pot': 'support@instantpot.com',
    'Keurig': 'support@keurig.com',
    'Nespresso': 'support@nespresso.com',

    // Automotive
    'Toyota': 'support@toyota.com',
    'Honda': 'support@honda.com',
    'Ford': 'support@ford.com',
    'Chevrolet': 'support@chevrolet.com',
    'BMW': 'support@bmw.com',
    'Mercedes-Benz': 'support@mercedes-benz.com',
    'Audi': 'support@audi.com',
    'Volkswagen': 'support@volkswagen.com',
    'Nissan': 'support@nissan.com',
    'Hyundai': 'support@hyundai.com',
    'Kia': 'support@kia.com',
    'Mazda': 'support@mazda.com',
    'Subaru': 'support@subaru.com',
    'Tesla': 'support@tesla.com',
    'Lexus': 'support@lexus.com',

    // Gaming
    'PlayStation': 'support@playstation.com',
    'Xbox': 'support@xbox.com',
    'Nintendo': 'support@nintendo.com',
    'Steam': 'support@steam.com',
    'Epic Games': 'support@epicgames.com',
    'Razer': 'support@razer.com',
    'Logitech': 'support@logitech.com',
    'Corsair': 'support@corsair.com',
    'SteelSeries': 'support@steelseries.com',
    'HyperX': 'support@hyperx.com',
    'ASUS ROG': 'support@asus.com',
    'MSI': 'support@msi.com',
    'Alienware': 'support@alienware.com',
    'NVIDIA': 'support@nvidia.com',
    'AMD': 'support@amd.com',
    'Intel': 'support@intel.com',

    // Tools & Equipment
    'DeWalt': 'support@dewalt.com',
    'Milwaukee': 'support@milwaukeetool.com',
    'Makita': 'support@makita.com',
    'Ryobi': 'support@ryobi.com',
    'Craftsman': 'support@craftsman.com',
    'Stanley': 'support@stanley.com',
    'Porter-Cable': 'support@portercable.com',
    'Snap-on': 'support@snapon.com',
    'Klein Tools': 'support@kleintools.com',
    'Fluke': 'support@fluke.com',

    // Home & Garden
    'IKEA': 'support@ikea.com',
    'Home Depot': 'support@homedepot.com',
    'Lowe\'s': 'support@lowes.com',
    'Wayfair': 'support@wayfair.com',
    'West Elm': 'support@westelm.com',
    'Pottery Barn': 'support@potterybarn.com',
    'Crate & Barrel': 'support@crateandbarrel.com',
    'Williams Sonoma': 'support@williamssonoma.com',
    'Ashley Furniture': 'support@ashleyfurniture.com',
    'La-Z-Boy': 'support@la-z-boy.com',
    'Tempur-Pedic': 'support@tempurpedic.com',
    'Sleep Number': 'support@sleepnumber.com',
    'Casper': 'support@casper.com',
    'Purple': 'support@purple.com',

    // Sports & Fitness
    'Nike': 'support@nike.com',
    'Adidas': 'support@adidas.com',
    'Under Armour': 'support@underarmour.com',
    'Puma': 'support@puma.com',
    'Reebok': 'support@reebok.com',
    'New Balance': 'support@newbalance.com',
    'Fitbit': 'support@fitbit.com',
    'Garmin': 'support@garmin.com',
    'Polar': 'support@polar.com',
    'Peloton': 'support@peloton.com',

    // Fashion & Accessories
    'Rolex': 'support@rolex.com',
    'Omega': 'support@omega.com',
    'TAG Heuer': 'support@tagheuer.com',
    'Seiko': 'support@seiko.com',
    'Citizen': 'support@citizen.com',
    'Casio': 'support@casio.com',
    'Fossil': 'support@fossil.com',
    'Michael Kors': 'support@michaelkors.com',
    'Coach': 'support@coach.com',
    'Louis Vuitton': 'support@louisvuitton.com',
    'Gucci': 'support@gucci.com',
    'Prada': 'support@prada.com',

    // Kitchen Appliances
    'Vitamix': 'support@vitamix.com',
    'Blendtec': 'support@blendtec.com',
    'NutriBullet': 'support@nutribullet.com',
    'Oster': 'support@oster.com',
    'Hamilton Beach': 'support@hamiltonbeach.com',
    'Mr. Coffee': 'support@mrcoffee.com',
    'Breville': 'support@breville.com',
    'DeLonghi': 'support@delonghi.com',
    'Smeg': 'support@smeg.com',
    'All-Clad': 'support@all-clad.com',
    'Le Creuset': 'support@lecreuset.com',
    'Zwilling': 'support@zwilling.com',
    'Wüsthof': 'support@wusthof.com',
    'Victorinox': 'support@victorinox.com',

    // More brands (shortened for space)
    'Miele': 'support@miele.com',
    'Kohler': 'support@kohler.com',
    'Moen': 'support@moen.com',
    'Delta Faucet': 'support@deltafaucet.com',
    'American Standard': 'support@americanstandard.com',
    'TOTO': 'support@toto.com',
    'Pentair': 'support@pentair.com',
    'Hayward': 'support@hayward.com',
    'Intex': 'support@intex.com',
    'Bestway': 'support@bestway.com',
    'Coleman': 'support@coleman.com',

    // Add more as needed without duplicates
  };

  /// Get the official warranty/support email for a manufacturer
  static String? getManufacturerEmail(String manufacturer) {
    return _manufacturerEmails[manufacturer];
  }

  /// Get all available manufacturers
  static List<String> getAllManufacturers() {
    return _manufacturerEmails.keys.toList()..sort();
  }

  /// Search manufacturers by name (case-insensitive)
  static List<String> searchManufacturers(String query) {
    if (query.isEmpty) return getAllManufacturers();

    final lowercaseQuery = query.toLowerCase();
    return _manufacturerEmails.keys
        .where(
          (manufacturer) => manufacturer.toLowerCase().contains(lowercaseQuery),
        )
        .toList()
      ..sort();
  }
}
