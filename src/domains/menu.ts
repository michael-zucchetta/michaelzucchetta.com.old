interface IStatus {

	url: string;

	templateUrl: string;

	controller: Function;

}

interface IMenuEl {
	id: number;

	name: string;

	status: IStatus;
	
	order: number;

	parentId?: number;

	active: boolean;

	children?: IMenuEl[];
	
	url: string;

	definition: string;
}

export default IMenuEl;
