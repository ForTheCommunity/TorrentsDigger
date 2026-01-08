use anyhow::anyhow;

use crate::sources::{Pagination, customs::{
    available_custom_sources::AllAvailableCustomSources,
    custom::{
        KnabenDatabaseCustomListings, NyaaCustomListings, SukebeiNyaaCustomListings,
        ThePirateBayCustomListings,
    },
}};

pub mod available_custom_sources;
pub mod custom;

pub fn search_custom(
    source_index: usize,
    listing_index: usize,
) -> Result<(Vec<crate::torrent::Torrent>, Pagination), anyhow::Error> {
    let custom_source_varient = AllAvailableCustomSources::from_index(source_index)
        .ok_or_else(|| anyhow!("Invalid Custom Listing Source Index: {}", source_index))?;
    match custom_source_varient {
        AllAvailableCustomSources::Nyaa => {
            let custom_listing_varient = NyaaCustomListings::from_index(listing_index)
                .ok_or_else(|| anyhow!("Invalid Custom Listing Index: {}", listing_index))?;
            NyaaCustomListings::fetch_torrents(custom_listing_varient)
        }
        AllAvailableCustomSources::SukebeiNyaa => {
            let custom_listing_varient = SukebeiNyaaCustomListings::from_index(listing_index)
                .ok_or_else(|| anyhow!("Invalid Custom Listing Index: {}", listing_index))?;
            SukebeiNyaaCustomListings::fetch_torrents(custom_listing_varient)
        }
        AllAvailableCustomSources::KnabenDatabase => {
            let custom_listing_varient = KnabenDatabaseCustomListings::from_index(listing_index)
                .ok_or_else(|| anyhow!("Invalid Custom Listing Index: {}", listing_index))?;
            KnabenDatabaseCustomListings::fetch_torrents(custom_listing_varient)
        }
        AllAvailableCustomSources::ThePirateBay => {
            let custom_listing_varient = ThePirateBayCustomListings::from_index(listing_index)
                .ok_or_else(|| anyhow!("Invalid Custom Listing Index: {}", listing_index))?;
            ThePirateBayCustomListings::fetch_torrents(custom_listing_varient)
        }
    }
}

pub fn get_custom_source_details() -> Vec<CustomSourceDetails> {
    let mut custom_sources: Vec<CustomSourceDetails> = Vec::new();

    let custom_nyaa = CustomSourceDetails {
        custom_source_name: AllAvailableCustomSources::Nyaa.to_string(),
        custom_source_listings: NyaaCustomListings::all_custom_listings(),
    };
    custom_sources.push(custom_nyaa);

    let custom_sukebei_nyaa = CustomSourceDetails {
        custom_source_name: AllAvailableCustomSources::SukebeiNyaa.to_string(),
        custom_source_listings: SukebeiNyaaCustomListings::all_custom_listings(),
    };
    custom_sources.push(custom_sukebei_nyaa);

    let custom_knaben_database = CustomSourceDetails {
        custom_source_name: AllAvailableCustomSources::KnabenDatabase.to_string(),
        custom_source_listings: KnabenDatabaseCustomListings::all_custom_listings(),
    };
    custom_sources.push(custom_knaben_database);

    let custom_pirate_bay = CustomSourceDetails {
        custom_source_name: AllAvailableCustomSources::ThePirateBay.to_string(),
        custom_source_listings: ThePirateBayCustomListings::all_custom_listings(),
    };
    custom_sources.push(custom_pirate_bay);

    custom_sources
}

pub struct CustomSourceDetails {
    pub custom_source_name: String,
    pub custom_source_listings: Vec<String>,
}
