import * as ADM  from  "./sql_admin.mjs"
import * as FW   from  "./sql_firmware.mjs"
import * as ORD  from  "./sql_order.mjs"
import * as PD   from  "./sql_product.mjs"
import * as AUTH from  "./sql_user.mjs"
import * as TST  from  "./sql_test.mjs"

//-----------------------------------------------------------------
// Admin scope
export function createEui(...args)              { return ADM.createEui(...args) }
export function createKt(...args)               { return ADM.createKt(...args) }
export function getKtInfo(...args)              { return ADM.getKtInfo(...args) }
export function getKtInfoRecursively(...args)   { return ADM.getKtInfoRecursively(...args) }
export function getBoardInfoByDevId(...args)    { return ADM.getBoardInfoByDevId(...args) }
export function getBoardInfoByEui(...args)      { return ADM.getBoardInfoByEui(...args) }
export function getSoftOptionsByScheme(...args) { return ADM.getSoftOptionsByScheme(...args) }
export function createOrder(...args)            { return ADM.createOrder(...args) }
export function getOrderInfo(...args)           { return ADM.getOrderInfo(...args) }
export function getDeviceInfoByOrder(...args)   { return ADM.getDeviceInfoByOrder(...args) }
export function getDeviceInfoByEui(...args)     { return ADM.getDeviceInfoByEui(...args) }

//-----------------------------------------------------------------
// Order scope
export function getOrders(...args)              { return ORD.getOrders(...args) }
export function getOrderByCode(...args)         { return ORD.getOrderByCode(...args) }
export function updateOrderIniCount(...args)    { return ORD.updateOrderIniCount(...args) }
export function incrementOrderIniCount(...args) { return ORD.incrementOrderIniCount(...args) }
export function decrementOrderIniCount(...args) { return ORD.decrementOrderIniCount(...args) }
export function getBoardKtByOrderCode(...args)  { return ORD.getBoardKtByOrderCode(...args) }
export function getHwTypeAttrByBoardKt(...args) { return ORD.getHwTypeAttrByBoardKt(...args) }
export function getOptionsForOrder(...args)     { return ORD.getOptionsForOrder(...args) }

//-----------------------------------------------------------------
// Product scope
export function getDevice(...args)                   { return PD.getDevice(...args) }
export function createDevice(...args)                { return PD.createDevice(...args) }
export function bindDeviceOption(...args)            { return PD.bindDeviceOption(...args) }
export function updateDeviceState(...args)           { return PD.updateDeviceState(...args) }
export function updateDeviceOrder(...args)           { return PD.updateDeviceOrder(...args) }
export function getEuiResource(...args)              { return PD.getEuiResource(...args) }
export function getFreeEuiResource(...args)          { return PD.getFreeEuiResource(...args) }
export function bindEuiResource(...args)             { return PD.bindEuiResource(...args) }
export function getLampType(...args)                 { return PD.getLampType(...args) }
export function addBindAttributes(...args)           { return PD.addBindAttributes(...args) }
export function addVendorAttributes(...args)         { return PD.addVendorAttributes(...args) }
export function getVendorAttributesByDevice(...args) { return PD.getVendorAttributesByDevice(...args) }

//-----------------------------------------------------------------
// Firmware scope
export function addFirmware(...args)           { return FW.addFirmware(...args) }
export function getProductFirmware(...args)    { return FW.getProductFirmware(...args) }
export function getLastFirmware(...args)       { return FW.getLastFirmware(...args) }
export function getFirmwareByVersion(...args)  { return FW.getFirmwareByVersion(...args) }

//-----------------------------------------------------------------
// Auth scope
export function addUser(...args)    { return AUTH.addUser(...args) }
export function checkUser(...args)  { return AUTH.checkUser(...args) }

//-----------------------------------------------------------------
// Test scope
// ...

