import FilterResource from '../model/FilterResource'
import IndexPath from '../model/IndexPath'
import { FilterModel } from '../model/FilterModel'
import { it } from '@ohos/hypium'

@Component
export struct FilterPanel {
  onFilterSelected?: (filter: FilterModel, currentCategory: number) => void
  onFilterStrengthChanged?: (filter: FilterModel, currentCategory: number) => void
  onFilterClose?: () => void
  filterResource: FilterResource = new FilterResource()
  @State currentCategory: number = 0
  private listController: Scroller = new Scroller()
  @State selectedIndexPath: IndexPath | null = null
  private selectedColor = Color.Red
  @State currentLength: number = 80;
  private  curFilter: FilterModel | null = null

  build() {
    Column() {
      Slider({
        value: this.currentLength,
        step: 1,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .visibility(this.selectedIndexPath && this.selectedIndexPath.category > 0 ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .showTips(true)
        .showSteps(true)
        .padding({ left: 20, right: 20 })
        .onChange((value: number, mode: SliderChangeMode) => {
          if (this.onFilterStrengthChanged !== undefined) {
            if(this.curFilter) {
              this.curFilter.value = value / 100;
              this.onFilterStrengthChanged(this.curFilter,this.currentCategory);
            }
          }
        })

      GridRow({
        columns: 4,
        // gutter: { x: 5, y: 10 },
        breakpoints: {
          value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize
        },
        direction: GridRowDirection.Row
      }) {
        ForEach(Array.from(this.filterResource.resource.keys()), (item: string, index) => {
          GridCol({ span: { xs: 1, sm: 1, md: 1, lg: 1 }, offset: 0, order: 0 }) {
            Column() {
              Text(item)// .margin({ top: 5 })
                .fontColor(this.currentCategory == index ? Color.Black : Color.Gray)
                .width("100%")
                .height('100%')
                .textAlign(TextAlign.Center)
                .fontSize(14)
            }
            .width("100%")
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .height('100%')
          .onClick(() => {
            if (this.currentCategory != index) {
              this.currentCategory = index
              let key = Array.from(this.filterResource.resource.keys())[this.currentCategory]
              console.log(`@mahaomeng key: ${key}`)
              this.listController.scrollToIndex(0)
            }
          })
        })
      }
      .width('100%')
      .height(40)
      .backgroundColor(Color.White)

      List({ scroller: this.listController, initialIndex: 0, space: 0 }) {
        ForEach(this.filterResource.resource.get(Array.from(this.filterResource.resource.keys())[this.currentCategory]), (item: FilterModel, index) => {
          ListItem() {
            Column() {
              Image($rawfile(item.icon))
                .height(50)
                .margin({ top: 10, bottom: 5 })
                .borderColor(this.selectedColor)
                .borderWidth(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? 2 : 0)
                .borderRadius(10)

              Text(item.name)
                .fontSize(10)
                .maxLines(1)
                .fontColor(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? this.selectedColor : Color.Black)
            }
            .width(60)
            .onClick(() => {
              if (this.selectedIndexPath?.category == this.currentCategory && this.selectedIndexPath?.index == index) {
                this.selectedIndexPath.index = -1
              } else {
                let selectedIndexPath = new IndexPath()
                selectedIndexPath.category = this.currentCategory
                selectedIndexPath.index = index
                this.selectedIndexPath = selectedIndexPath
              }
              if (this.onFilterSelected !== undefined) {
                this.curFilter = item;
                this.onFilterSelected(item, this.currentCategory)
                if (this.currentCategory == 1 || this.currentCategory == 2 || this.currentCategory == 3) {
                  if (item.value) {
                    this.currentLength = item.value * 100;
                  } else  {
                    this.currentLength = 20;
                  }
                }
              }
            })
          }
        })
      }
      .height('100%')
      .width('100%')
      .listDirection(Axis.Horizontal)
      .backgroundColor(Color.White)
    }
  }

  onDidBuild(): void {
    if (this.onFilterSelected !== undefined) {
      this.filterResource.resource.forEach((filterModels, key) => {
        // 遍历每个 FilterModel
        for (const filterModel of filterModels) {
          if (filterModel.type! == 1 ||filterModel.type! == 2) {//美颜给默认值
            this.onFilterSelected!(filterModel, filterModel.type!);
          }

        }
      });
    }
  }
}