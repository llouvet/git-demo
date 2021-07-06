import { LightningElement, track } from 'lwc';

export default class timezoneConverter extends LightningElement {

    @track dateTimeField = '2020-09-12T18:13:41Z';
    @track value = 'America/Atikokan';
    @track timeZone = 'America/Atikokan';
    @track dateTimeValue = '2020-09-12T18:13:41Z';


    get options() {
        return [
            { label: 'EST (America/Atikokan)', value: 'America/Atikokan' },
            { label: 'PST (America/Vancouver)', value: 'America/Vancouver' },
            { label: 'CST (America/Regina)', value: 'America/Regina' },
            { label: 'SGT (Asia/Singapore)', value: 'Asia/Singapore' },
        ];
    }

    handleChange(event) {
        this.timeZone = event.detail.value;
    }

    handleInput(event){
        this.dateTimeField = event.detail.value;
    }
}