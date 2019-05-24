# zabbix_adaptec_template
## Description

This template is for discovering and monitoring adaptec storage controllers by using outputs of arcconf cli tool. Useful only if you have 
one adaptec adapter in server (i don't have servers with more fore testing). Now it works only with zabbix 4.2

## Main features

* Discovery of controllers, logical discs, physical discs, batteries
* Monitoring controllers, logical, physical discs, batteries
* Comfortable changing of time intervals by macroses.

## Installation

### Zabbix server

* Import template
* Create and configure global or template macroses:
  * {$ADAP_DISCOVERY_PERIOD} - adapters discovery period. I think you can set it nearly 1d (daily)
  * {$ADAP_HISTORY_PERIOD} - period of saving history for adapters data. For example 30d
  * {$ADAP_REQUEST_PERIOD} - period of requesting storage adapters data ( adapter,battery state, etc). 1h
  * {$INTERNAL_ITEMS_HISTORY_PEIOD} - period of source data for parsing items by json path. Usually 0, but for 
  debugging you can set it higher
  * {$LD_DISCOVERY_PERIOD} - logical discs discovery period. 6h
  * {$LD_HISTORY_PERIOD} - period of saving history for logical discs data. 30d
  * {$LD_REQUEST_PERIOD} - period of requesting logical discs data. 5m
  * {$PD_DISCOVERY_PERIOD} - physical discs discovery period. 30m
  * {$PD_HISTORY_PERIOD} - period of saving history for physical discs data. 30d
  * {$PD_REQUEST_PERIOD} - period of requesting physical discs data. 5m
   * {$ADAP_THROTTLING_HB_PERIOD} - period of heartbit for throttling for adapter data
   * {$LD_THROTTLING_HB_PERIOD} - period of heartbit for throttling for logical discs data
   * {$PD_THROTTLING_HB_PERIOD} - period of heartbit for throttling for physical discs data.
  
