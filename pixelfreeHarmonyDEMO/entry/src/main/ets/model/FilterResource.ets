import { JSON } from '@kit.ArkTS';
import { util } from '@kit.ArkTS';
import { FilterModel,FilterModeGroup } from './FilterModel'

export default class FilterResource {
  public resource: Map<string, FilterModel[]>

  constructor() {
    this.resource = new Map<string, FilterModel[]>()
    this.getAllFilters()
  }

  private getAllFilters() {
    let context = getContext(this)
    let resourceManager = context.resourceManager
    let fileList = resourceManager.getRawFileListSync('pixelfree')

    let fileContent = context.resourceManager.getRawFileContentSync("pixelfree/pixelfree_filter.json")
    let decoder = util.TextDecoder.create();
    let jsonStr = decoder.decodeToString(fileContent)
    if (jsonStr.length <= 0) {
      return
    }
    let modelArray: FilterModeGroup[];
    modelArray = JSON.parse(jsonStr) as FilterModeGroup[];
    for (let index = 0; index < modelArray.length; index++) {
         let filterCategory = modelArray[index]
         this.resource.set(filterCategory.name as string, filterCategory.value)
    }
  }
}