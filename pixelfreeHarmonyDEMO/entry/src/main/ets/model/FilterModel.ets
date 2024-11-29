
@Observed


export class FilterModel  {
  type : number | undefined
  name : string | undefined
  value : number | undefined
  value_str : string | undefined
  icon : string | undefined
  value_type : number | undefined

  constructor(name?:string, icon?:string, value_str?:string,value?:number) {
    this.name = name
    this.icon = icon
    this.value_str = value_str
    this.value = value
  }
}

export class FilterModeGroup  {
  name : string | undefined
  value: FilterModel[] = []
  type : number | undefined
}

type FilterData = FilterModeGroup[];