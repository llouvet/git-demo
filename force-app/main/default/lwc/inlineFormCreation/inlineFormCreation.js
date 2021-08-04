import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";

export default class InlineFormCreation extends NavigationMixin(
  LightningElement
) {
  objApiName = "Account";
  fields = [
    { name: "Name", value: "" },
    { name: "Phone", value: "123465" },
    { name: "Industry", value: "" },
    { name: "Type", value: "" },
    { name: "Website", value: "" }
  ];
  @api recordId;

  keyIndex = 0;
  itemList = [{ id: 0 }];

  addRow() {
    ++this.keyIndex;
    let newItem = [{ id: this.keyIndex }];
    this.itemList = this.itemList.concat(newItem);
  }

  removeRow(event) {
    if (this.itemList.length >= 2) {
      this.itemList = this.itemList.filter((element) => {
        return (
          parseInt(element.id, 10) !== parseInt(event.target.accessKey, 10)
        );
      });
    }
  }

  handleSubmit() {
    var isVal = true;
    this.template
      .querySelectorAll("lightning-input-field")
      .forEach((element) => {
        isVal = isVal && element.reportValidity();
      });
    if (isVal) {
      this.template
        .querySelectorAll("lightning-record-edit-form")
        .forEach((element) => {
          element.submit();
        });
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Contacts successfully created",
          variant: "success"
        })
      );
      this.dispatchEvent(new CloseActionScreenEvent());
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error creating record",
          message: "Please enter all the required fields",
          variant: "error"
        })
      );
    }
  }
}
