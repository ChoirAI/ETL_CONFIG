DROP INDEX IF EXISTS instrtyproductcycledata_insid_idx;
CREATE INDEX instrtyproductcycledata_insid_idx ON public."InsTrtyProductCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle");
DROP INDEX IF EXISTS instrtyproductcycledata_insid_idx2;
CREATE INDEX instrtyproductcycledata_insid_idx2 ON public."InsTrtyProductCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID");

DROP INDEX IF EXISTS itpccd_pk_idx;
CREATE INDEX itpccd_pk_idx ON public."InsTrtyProductChannelCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle", "SubInsType");
DROP INDEX IF EXISTS itpccd_pk_idx2;
CREATE INDEX itpccd_pk_idx2 ON public."InsTrtyProductChannelCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle");

DROP INDEX IF EXISTS instrtyproductcycletarget_insid_idx;
CREATE INDEX instrtyproductcycletarget_insid_idx ON public."InsTrtyProductCycleTarget" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle");

DROP INDEX IF EXISTS insprodlistingevent_productid_idx;
CREATE INDEX insprodlistingevent_productid_idx ON public."InsProdListingEvent" USING btree ("ProductID", "ListingStatus");